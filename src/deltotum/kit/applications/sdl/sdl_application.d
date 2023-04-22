module deltotum.kit.applications.sdl.sdl_application;

import deltotum.core.applications.application_exit : ApplicationExit;
import deltotum.core.applications.graphic_application : GraphicApplication;
import deltotum.kit.applications.components.graphics_component : GraphicsComponent;
import deltotum.kit.events.event_manager : EventManager;
import deltotum.sys.sdl.events.sdl_event_processor : SdlEventProcessor;
import deltotum.kit.asset.assets : Assets;
import deltotum.kit.asset.fonts.font : Font;
import deltotum.kit.scene.scene_manager : SceneManager;
import deltotum.media.audio.audio : Audio;
import deltotum.kit.graphics.graphics : Graphics;
import deltotum.kit.display.display_object : DisplayObject;
import deltotum.kit.scene.scene : Scene;
import deltotum.kit.input.keyboard.event.key_event : KeyEvent;
import deltotum.kit.input.joystick.event.joystick_event : JoystickEvent;

import deltotum.sys.sdl.sdl_lib : SdlLib;
import deltotum.sys.sdl.img.sdl_img_lib : SdlImgLib;
import deltotum.sys.sdl.mix.sdl_mix_lib : SdlMixLib;
import deltotum.sys.sdl.ttf.sdl_ttf_lib : SdlTTFLib;
import deltotum.sys.sdl.sdl_window : SdlWindow;
import deltotum.sys.sdl.sdl_renderer : SdlRenderer;
import deltotum.sys.sdl.sdl_joystick : SdlJoystick;
import deltotum.kit.window.event.window_event : WindowEvent;
import deltotum.kit.input.mouse.event.mouse_event : MouseEvent;

import std.typecons : Nullable;

import deltotum.kit.window.window : Window;
import deltotum.kit.input.input : Input;

import std.logger : Logger, MultiLogger, FileLogger, LogLevel, sharedLog;
import std.stdio;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlApplication : GraphicApplication
{
    Window[] windows;

    private
    {
        SdlLib sdlLib;
        SdlImgLib imgLib;
        SdlMixLib audioMixLib;
        SdlTTFLib fontLib;
        SdlJoystick joystick;

        //TODO check overflow and remove increment
        double deltaTime = 0;
        double deltaTimeAccumulator = 0;
        double lastUpdateTime = 0;

        Audio _audio;
        Assets _assets;
        Input _input;
    }

    bool isRunning;
    EventManager eventManager;

    this(SdlLib lib = null, SdlImgLib imgLib = null, SdlMixLib audioMixLib = null, SdlTTFLib fontLib = null)
    {
        this.sdlLib = lib is null ? new SdlLib : lib;
        this.imgLib = imgLib is null ? new SdlImgLib : imgLib;
        this.audioMixLib = audioMixLib is null ? new SdlMixLib : audioMixLib;
        this.fontLib = fontLib is null ? new SdlTTFLib : fontLib;
    }

    override ApplicationExit initialize(string[] args)
    {
        if (auto isExit = super.initialize(args))
        {
            return isExit;
        }

        sdlLib.initialize(SDL_INIT_VIDEO | SDL_INIT_TIMER | SDL_INIT_AUDIO | SDL_INIT_JOYSTICK);
        uservices.logger.trace("SDL ", sdlLib.getSdlVersionInfo);

        //TODO move to hal layer
        SDL_LogSetPriority(SDL_LOG_CATEGORY_APPLICATION, SDL_LOG_PRIORITY_WARN);

        imgLib.initialize;
        audioMixLib.initialize;
        fontLib.initialize;

        joystick = SdlJoystick.fromDevices;

        //TODO extreact dependency
        import deltotum.sys.sdl.sdl_keyboard : SdlKeyboard;

        auto keyboard = new SdlKeyboard;

        import deltotum.kit.input.clipboards.clipboard : Clipboard;
        import deltotum.sys.sdl.sdl_clipboard;

        auto sdlClipboard = new SdlClipboard;
        auto clipboard = new Clipboard(sdlClipboard);
        _input = new Input(clipboard);
        _audio = new Audio(audioMixLib);

        //TODO remove sdl api
        eventManager = new EventManager();
        eventManager.targetsProvider = () {
            auto mustBeCurrentWindow = currentWindow;
            if (mustBeCurrentWindow.isNull)
            {
                return Nullable!(DisplayObject[]).init;
            }
            auto targets = mustBeCurrentWindow.get.sceneManager.currentScene.getActiveObjects;
            return Nullable!(DisplayObject[])(targets);
        };
        eventManager.eventProcessor = new SdlEventProcessor(keyboard);
        eventManager.onKey = (key) {
            if (key.event == KeyEvent.Event.keyDown)
            {
                _input.addPressedKey(key.keyCode);
            }
            else if (key.event == KeyEvent.Event.keyUp)
            {
                _input.addReleasedKey(key.keyCode);
            }
        };
        eventManager.onJoystick = (joystickEvent) {

            if (joystickEvent.event == JoystickEvent.Event.axis)
            {
                if (_input.justJoystickActive)
                {
                    _input.justJoystickChangeAxis = joystickEvent.axis != _input
                        .lastJoystickEvent.axis;
                    _input.justJoystickChangesAxisValue = _input.lastJoystickEvent.axisValue != joystickEvent
                        .axisValue;
                    _input.joystickAxisDelta = joystickEvent.axisValue - _input
                        .lastJoystickEvent.axisValue;
                }
            }
            else if (joystickEvent.event == JoystickEvent.Event.press)
            {
                _input.justJoystickPressed = true;
            }
            else if (joystickEvent.event == JoystickEvent.Event.release)
            {
                _input.justJoystickPressed = false;
            }

            _input.lastJoystickEvent = joystickEvent;
            if (!_input.justJoystickActive)
            {
                _input.justJoystickActive = true;
            }
        };

        eventManager.onWindow = (e) {
            if (e.event == WindowEvent.Event.WINDOW_FOCUS_IN)
            {
                foreach (Window window; windows)
                {
                    if (window.id == e.ownerId)
                    {
                        //TODO check all windows
                        window.isFocus = true;
                    }
                }
            }
            else if (e.event == WindowEvent.Event.WINDOW_FOCUS_OUT)
            {
                foreach (Window window; windows)
                {
                    if (window.id == e.ownerId)
                    {
                        //TODO check all windows
                        window.isFocus = false;
                    }
                }
            }
            else if (e.event == WindowEvent.Event.WINDOW_SHOW)
            {
                foreach (Window window; windows)
                {
                    if (window.id == e.ownerId)
                    {
                        //TODO check all windows
                        window.isShowing = true;
                    }
                }
            }
            else if (e.event == WindowEvent.Event.WINDOW_HIDE)
            {
                foreach (Window window; windows)
                {
                    if (window.id == e.ownerId)
                    {
                        //TODO check all windows
                        window.isShowing = false;
                    }
                }
            }
            else if (e.event == WindowEvent.Event.WINDOW_CLOSE)
            {
                Window windowForClosing;
                foreach (Window window; windows)
                {
                    if (window.id == e.ownerId)
                    {
                        windowForClosing = window;
                        break;
                    }
                }
                if (windowForClosing !is null)
                {
                    import std.algorithm.mutation : remove;
                    import std.algorithm.searching : countUntil;

                    immutable ptrdiff_t removePos = windows.countUntil(windowForClosing);
                    if (removePos != -1)
                    {
                        windows = windows.remove(removePos);
                    }
                    windowForClosing.destroy;
                }

                // if(windows.length == 0){
                //     quit;
                // }
            }
        };

        eventManager.onMouse = (mouseEvent) {
            if (mouseEvent.event == MouseEvent.Event.mouseDown)
            {
                auto mustBeWindow = currentWindow;
                if (mustBeWindow.isNull)
                {
                    return;
                }
                auto window = mustBeWindow.get;
                foreach (obj; window.sceneManager.currentScene.getActiveObjects)
                {
                    if (obj.bounds.contains(mouseEvent.x, mouseEvent.y))
                    {
                        if (!obj.isFocus)
                        {
                            obj.isFocus = true;
                        }

                        import deltotum.kit.display.events.focus.focus_event : FocusEvent;
                        import deltotum.core.events.event_type : EventType;

                        auto focusEvent = FocusEvent(EventType.focus, FocusEvent.Event.focusIn, mouseEvent
                                .ownerId, mouseEvent.x, mouseEvent.y);
                        eventManager.dispatchEvent(focusEvent, obj);

                        //for children
                        auto focusOutEvent = FocusEvent(EventType.focus, FocusEvent.Event.focusOut, mouseEvent
                                .ownerId, mouseEvent.x, mouseEvent.y);
                        eventManager.dispatchEvent(focusOutEvent, obj);
                    }
                    else
                    {
                        if (obj.isFocus)
                        {
                            obj.isFocus = false;
                            import deltotum.kit.display.events.focus.focus_event : FocusEvent;
                            import deltotum.core.events.event_type : EventType;

                            auto focusEvent = FocusEvent(EventType.focus, FocusEvent.Event.focusOut, mouseEvent
                                    .ownerId, mouseEvent.x, mouseEvent.y);
                            eventManager.dispatchEvent(focusEvent, obj);
                        }
                    }
                }
            }
        };

        eventManager.startEvents;

        //TODO move to config
        import std.file : getcwd, exists, isDir;
        import std.path : buildPath, dirName;

        immutable assetsDirPath = "data/assets";
        immutable assetsDir = buildPath(getcwd, assetsDirPath);
        if (!exists(assetsDir) || !isDir(assetsDir))
        {
            throw new Exception("Unable to find resource directory: " ~ assetsDir);
        }

        _assets = new Assets(uservices.logger, assetsDir);

        //TODO from config
        Font defaultFont = _assets.font("fonts/NotoSans-Bold.ttf", 14);
        _assets.defaultFont = defaultFont;

        isRunning = true;
        return ApplicationExit(false);
    }

    Window createWindow(string title, int prefWidth, int prefHeight)
    {
        auto sdlWindow = new SdlWindow(title, SDL_WINDOWPOS_UNDEFINED,
            SDL_WINDOWPOS_UNDEFINED,
            prefWidth,
            prefHeight);

        auto sdlRenderer = new SdlRenderer(sdlWindow, SDL_RENDERER_ACCELERATED);
        uint id;
        if (const err = sdlWindow.windowId(id))
        {
            throw new Exception(err.toString);
        }
        auto window = new Window(sdlRenderer, sdlWindow, id);

        GraphicsComponent builder = new GraphicsComponent;
        build(builder);

        builder.input = _input;
        builder.assets = _assets;
        builder.audio = _audio;

        //TODO remove
        window.frameRate = frameRate;
        builder.window = window;

        import deltotum.kit.graphics.themes.theme : Theme;
        import deltotum.kit.graphics.themes.factories.theme_from_config_factory : ThemeFromConfigFactory;

        auto themeLoader = new ThemeFromConfigFactory(uservices.logger, uservices.config, uservices.context, _assets
                .defaultFont);

        auto theme = themeLoader.create;
        builder.graphics = new Graphics(uservices.logger, window.renderer, theme);

        builder.isBuilt = true;

        import deltotum.gui.fonts.bitmap.bitmap_font_generator : BitmapFontGenerator;

        //TODO build and run services after all
        import deltotum.gui.fonts.bitmap.bitmap_font : BitmapFont;

        //TODO from locale\config;
        import deltotum.kit.i18n.langs.alphabets.alphabet_ru : AlphabetRu;
        import deltotum.kit.i18n.langs.alphabets.alphabet_en : AlphabetEn;
        import deltotum.kit.i18n.langs.alphabets.arabic_numerals_alphabet : ArabicNumeralsAlpabet;
        import deltotum.kit.i18n.langs.alphabets.special_characters_alphabet : SpecialCharactersAlphabet;

        auto fontGenerator = new BitmapFontGenerator;
        builder.build(fontGenerator);
        import deltotum.kit.graphics.colors.rgba : RGBA;

        //FIXME, extract default font from global assets
        _assets.defaultBitmapFont = fontGenerator.generate([
            new ArabicNumeralsAlpabet,
            new SpecialCharactersAlphabet,
            new AlphabetEn,
            new AlphabetRu
        ], _assets.defaultFont, theme.colorText);

        auto sceneManager = new SceneManager;
        builder.build(sceneManager);
        window.sceneManager = sceneManager;
        windows ~= window;

        return window;
    }

    override void runWait()
    {
        while (isRunning)
        {
            update;
        }
    }

    void clearErrors()
    {
        sdlLib.clearError;
    }

    override void quit()
    {
        clearErrors;

        foreach (window; windows)
        {
            window.destroy;
        }

        //TODO auto destroy all services
        _audio.destroy;

        if (joystick !is null)
        {
            joystick.destroy;
        }

        //TODO process EXIT event
        audioMixLib.quit;
        imgLib.quit;
        sdlLib.quit;
        fontLib.quit;
    }

    void updateState(double delta)
    {
        foreach (window; windows)
        {
            if (window.isShowing)
            {
                //window.renderer.clear;
                window.update(delta);
                break;
                //window.renderer.present;
            }
        }
    }

    Nullable!Window currentWindow()
    {
        foreach (window; windows)
        {
            if (window.isShowing)
            {
                return Nullable!Window(window);
            }
        }

        return Nullable!Window.init;
    }

    override bool update()
    {
        enum msInSec = 1000;
        const frameTime = msInSec / frameRate;

        //TODO SDL_GetPerformanceCounter
        //(double)((now - start)*1000) / SDL_GetPerformanceFrequency()
        const start = SDL_GetTicks();
        deltaTime = start - lastUpdateTime;
        lastUpdateTime = start;
        deltaTimeAccumulator += deltaTime;

        SDL_Event event;

        auto mustBeWindow = currentWindow;

        if (!mustBeWindow.isNull)
        {
            mustBeWindow.get.sceneManager.currentScene.timeEventProcessingMs = 0;
        }

        while (SDL_PollEvent(&event))
        {
            const startEvent = SDL_GetTicks();
            handleEvent(&event);
            const endEvent = SDL_GetTicks();

            if (!mustBeWindow.isNull)
            {
                mustBeWindow.get.sceneManager.currentScene.timeEventProcessingMs = endEvent - startEvent;
            }

            if (!isRunning)
            {
                return isRunning;
            }
        }

        while (deltaTimeAccumulator > frameTime)
        {
            immutable constantDelta = frameTime / 100;
            const startStateTime = SDL_GetTicks();
            updateState(constantDelta);
            const endStateTime = SDL_GetTicks();

            if (!mustBeWindow.isNull)
            {
                mustBeWindow.get.sceneManager.currentScene.timeUpdateProcessingMs = endStateTime - startStateTime;
            }

            deltaTimeAccumulator -= frameTime;
        }

        return true;
    }

    void handleEvent(SDL_Event* event)
    {
        eventManager.eventProcessor.process(event);

        if (event.type == SDL_QUIT)
        {
            isRunning = false;
            return;
        }
    }
}
