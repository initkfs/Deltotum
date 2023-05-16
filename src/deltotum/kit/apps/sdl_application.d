module deltotum.kit.apps.sdl_application;

// dfmt off
version(SdlBackend):
// dfmt on

import deltotum.core.configs.config : Config;
import deltotum.core.contexts.context : Context;
import deltotum.core.apps.application_exit : ApplicationExit;
import deltotum.kit.apps.graphic_application : GraphicApplication;
import deltotum.kit.apps.components.graphics_component : GraphicsComponent;
import deltotum.kit.events.event_manager : EventManager;
import deltotum.sys.sdl.events.sdl_event_processor : SdlEventProcessor;
import deltotum.kit.scenes.scene_manager : SceneManager;
import deltotum.media.audio.audio : Audio;
import deltotum.kit.graphics.graphics : Graphics;
import deltotum.kit.interacts.interact : Interact;
import deltotum.kit.sprites.sprite : Sprite;
import deltotum.kit.scenes.scene : Scene;
import deltotum.kit.inputs.keyboards.events.key_event : KeyEvent;
import deltotum.kit.inputs.joysticks.events.joystick_event : JoystickEvent;
import deltotum.kit.extensions.extension : Extension;
import deltotum.sys.sdl.sdl_lib : SdlLib;
import deltotum.sys.sdl.img.sdl_img_lib : SdlImgLib;
import deltotum.sys.sdl.mix.sdl_mix_lib : SdlMixLib;
import deltotum.sys.sdl.ttf.sdl_ttf_lib : SdlTTFLib;
import deltotum.sys.sdl.sdl_window : SdlWindow;
import deltotum.sys.sdl.sdl_window : SdlWindowMode;
import deltotum.sys.sdl.sdl_renderer : SdlRenderer;
import deltotum.sys.sdl.sdl_joystick : SdlJoystick;
import deltotum.kit.windows.events.window_event : WindowEvent;
import deltotum.kit.inputs.mouse.events.mouse_event : MouseEvent;

import deltotum.kit.windows.window : Window;
import deltotum.kit.screens.screen : Screen;

import deltotum.kit.apps.loops.integrated_loop : IntegratedLoop;
import deltotum.kit.apps.loops.loop : Loop;
import deltotum.kit.windows.window_manager : WindowManager;
import deltotum.kit.apps.capabilities.capability : Capability;

import std.typecons : Nullable;

import deltotum.kit.inputs.input : Input;

import std.logger : Logger, MultiLogger, FileLogger, LogLevel, sharedLog;
import std.stdio;

import deltotum.sys.cairo.libs : CairoLib;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlApplication : GraphicApplication
{
    private
    {
        SdlLib sdlLib;
        SdlMixLib audioMixLib;
        SdlImgLib imgLib;
        SdlTTFLib fontLib;
        SdlJoystick joystick;

        Audio _audio;
        Extension _ext;
        Input _input;
        Screen _screen;

        CairoLib cairoLib;
    }

    EventManager eventManager;

    this(SdlLib lib = null,
        SdlImgLib imgLib = null,
        SdlMixLib audioMixLib = null,
        SdlTTFLib fontLib = null,
        Loop mainLoop = null)
    {
        super(mainLoop ? mainLoop : new IntegratedLoop);
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

        mainLoop.onQuit = () => quit;
        mainLoop.timestampMsProvider = () => sdlLib.getTicks;
        mainLoop.onDelay = () => sdlLib.delay(20);
        mainLoop.onLoopUpdateMs = (timestamp) => updateLoopMs(timestamp);
        mainLoop.onRender = () => updateRender;
        mainLoop.onFreqLoopUpdateDelta = (delta) => updateFreqLoopDelta(delta);

        sdlLib.initialize(SDL_INIT_VIDEO | SDL_INIT_TIMER | SDL_INIT_AUDIO | SDL_INIT_JOYSTICK);
        uservices.logger.trace("SDL ", sdlLib.getSdlVersionInfo);

        //TODO move to hal layer
        SDL_LogSetPriority(SDL_LOG_CATEGORY_APPLICATION, SDL_LOG_PRIORITY_WARN);

        imgLib.initialize;
        audioMixLib.initialize;
        fontLib.initialize;

        joystick = SdlJoystick.fromDevices;

        //TODO extract dependency
        import deltotum.sys.sdl.sdl_keyboard : SdlKeyboard;

        auto keyboard = new SdlKeyboard;

        import deltotum.kit.inputs.clipboards.clipboard : Clipboard;
        import deltotum.sys.sdl.sdl_clipboard;

        auto sdlClipboard = new SdlClipboard;
        auto clipboard = new Clipboard(sdlClipboard);

        import deltotum.kit.inputs.cursors.system_cursor : SystemCursor;
        import deltotum.sys.sdl.sdl_cursor : SDLCursor;

        auto cursor = new SystemCursor;
        cursor.cursorFactory = (type) {
            auto newCursor = new SDLCursor(type);
            return newCursor;
        };

        _input = new Input(clipboard, cursor);
        _audio = new Audio(audioMixLib);

        auto cairoLibForLoad = new CairoLib;

        cairoLibForLoad.onAfterLoad = () {
            cairoLib = cairoLibForLoad;
            _cap.isVectorGraphics = true;
            uservices.logger.trace("Load Cairo library.");
        };

        cairoLibForLoad.onNoLibrary = () => uservices.logger.error("Cairo library loading error.");
        cairoLibForLoad.onBadLibrary = () => uservices.logger.error("Cairo bad library.");
        cairoLibForLoad.onErrorWithMessage = (err, msg) {
            import std.string : fromStringz;

            uservices.logger.errorf("Cairo loading error. %s: %s\n", err.fromStringz.idup, msg
                    .fromStringz.idup);
            cairoLibForLoad.unload;
            cairoLib = null;
        };

        cairoLibForLoad.load;

        //TODO version
        import bindbc.freeimage;

        FISupport ret = loadFreeImage();
        if (ret == fiSupport)
        {
            _cap.isImageProcessing = true;
            uservices.logger.trace("Load FreeImage library");
        }
        else
        {
            if (ret == FISupport.noLibrary)
            {
                uservices.logger.warning("FreeImage shared library failed to load");
            }
            else if (FISupport.badLibrary)
            {
                //TODO all errors
                uservices.logger.warning("FreeImage bad library");
            }
            else
            {
                uservices.logger.warning("FreeImage library loading error");
            }
        }

        _ext = createExtension(uservices.logger, uservices.config, uservices.context);

        import deltotum.sys.sdl.sdl_screen : SDLScreen;

        auto sdlScreen = new SDLScreen;
        _screen = new Screen(uservices.logger, sdlScreen);

        eventManager = new EventManager();
        eventManager.targetsProvider = (windowId) {
            auto mustBeCurrentWindow = windowManager.windowByFirstId(windowId);
            if (mustBeCurrentWindow.isNull)
            {
                return Nullable!(Sprite[]).init;
            }
            auto currWindow = mustBeCurrentWindow.get;
            if (!currWindow.isShowing || !currWindow.isFocus)
            {
                return Nullable!(Sprite[]).init;
            }
            auto targets = currWindow.scenes.currentScene.getActiveObjects;
            return Nullable!(Sprite[])(targets);
        };

        eventManager.eventProcessor = new SdlEventProcessor(keyboard);
        eventManager.onKey = (key) {
            final switch (key.event) with (KeyEvent.Event)
            {
            case keyDown:
                _input.addPressedKey(key.keyCode);
                break;
            case keyUp:
                _input.addReleasedKey(key.keyCode);
                break;
            case none:
                break;
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
            switch (e.event) with (WindowEvent.Event)
            {
            case focusIn:
                windowManager.windowById(e.ownerId, (win) {
                    win.isFocus = true;
                    return true;
                });
                break;
            case focusOut:
                windowManager.windowById(e.ownerId, (win) {
                    win.isFocus = false;
                    return true;
                });
                break;
            case show:
                windowManager.windowById(e.ownerId, (win) {
                    win.isShowing = true;
                    return true;
                });
                break;
            case hide:
                windowManager.windowById(e.ownerId, (win) {
                    win.isShowing = false;
                    return true;
                });
                break;
            case resize:
                windowManager.windowById(e.ownerId, (win) {
                    win.confirmResize(e.width, e.height);
                    return true;
                });
                break;
            case close:
                closeWindow(e.ownerId);
                break;
            default:
                break;
            }
        };

        eventManager.onMouse = (mouseEvent) {
            if (mouseEvent.event == MouseEvent.Event.mouseDown)
            {
                auto mustBeWindow = windowManager.currentWindow;
                if (mustBeWindow.isNull)
                {
                    return;
                }
                auto window = mustBeWindow.get;
                foreach (obj; window.scenes.currentScene.getActiveObjects)
                {
                    if (obj.bounds.contains(mouseEvent.x, mouseEvent.y))
                    {
                        if (!obj.isFocus)
                        {
                            obj.isFocus = true;
                        }

                        import deltotum.kit.sprites.events.focus.focus_event : FocusEvent;
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
                            import deltotum.kit.sprites.events.focus.focus_event : FocusEvent;
                            import deltotum.core.events.event_type : EventType;

                            auto focusEvent = FocusEvent(EventType.focus, FocusEvent.Event.focusOut, mouseEvent
                                    .ownerId, mouseEvent.x, mouseEvent.y);
                            eventManager.dispatchEvent(focusEvent, obj);
                        }
                    }
                }
            }
        };

        windowManager = new WindowManager;

        //TODO move to config
        import std.file : getcwd, exists, isDir;
        import std.path : buildPath, dirName;

        eventManager.startEvents;

        return ApplicationExit(false);
    }

    protected void buildPartially(GraphicsComponent component)
    {
        import deltotum.core.apps.uni.uni_component : UniComponent;

        super.build(cast(UniComponent) component);

        component.isBuilt = false;

        component.audio = _audio;
        component.input = _input;
        component.screen = _screen;
        component.ext = _ext;
        component.cap = _cap;
    }

    Window newWindow(
        dstring title,
        int width,
        int height,
        int x,
        int y,
        Window parent = null,
        SdlWindowMode mode = SdlWindowMode.none)
    {
        import deltotum.kit.windows.window : Window;
        import deltotum.kit.scenes.scene_manager : SceneManager;
        import deltotum.sys.sdl.sdl_window : SdlWindow, SdlWindowMode;
        import deltotum.sys.sdl.sdl_renderer : SdlRenderer;

        import std.conv : to;

        auto sdlWindow = new SdlWindow;
        sdlWindow.mode = mode;

        auto windowBuilder = newGraphicServices;
        buildPartially(windowBuilder);

        auto window = new Window(uservices.logger, sdlWindow);
        windowBuilder.window = window;

        if (parent)
        {
            window.parent = parent;
            window.frameRate = parent.frameRate;
            window.windowManager = parent.windowManager;
        }
        else
        {
            window.frameRate = mainLoop.frameRate;
            window.windowManager = windowManager;
        }

        window.childWindowProvider = (title, width, height, x, y, parent) {
            return newWindow(title, width, height, x, y, parent);
        };

        window.initialize;
        window.create;

        window.setNormalWindow;

        window.setSize(width, height);

        const int newX = (x == -1) ? SDL_WINDOWPOS_UNDEFINED : x;
        const int newY = (y == -1) ? SDL_WINDOWPOS_UNDEFINED : y;

        window.setPos(newX, newY);

        //TODO extract renderer
        SdlRenderer sdlRenderer = new SdlRenderer(sdlWindow, SDL_RENDERER_ACCELERATED | SDL_RENDERER_TARGETTEXTURE);
        window.setTitle(title);

        //TODO move to config, duplication with SdlApplication
        import std.file : getcwd, exists, isDir;
        import std.path : buildPath, dirName;

        immutable assetsDirPath = "data/assets";
        immutable assetsDir = buildPath(getcwd, assetsDirPath);

        import deltotum.kit.assets.asset : Asset;

        windowBuilder.asset = new Asset(uservices.logger, assetsDir);

        import deltotum.kit.gui.themes.theme : Theme;
        import deltotum.kit.gui.themes.factories.theme_from_config_factory : ThemeFromConfigFactory;

        auto themeLoader = new ThemeFromConfigFactory(uservices.logger, uservices.config, uservices.context, windowBuilder
                .asset
                .defaultFont);

        auto theme = themeLoader.create;

        import deltotum.kit.assets.fonts.font : Font;

        Font defaultFont = windowBuilder.asset.font("fonts/NotoSans-Bold.ttf", 14);
        windowBuilder.asset.defaultFont = defaultFont;

        import deltotum.kit.graphics.graphics : Graphics;

        windowBuilder.graphics = new Graphics(uservices.logger, sdlRenderer, theme);
        windowBuilder.graphics.comTextureFactory = () {
            import deltotum.sys.sdl.sdl_texture : SdlTexture;

            return new SdlTexture(sdlRenderer);
        };

        windowBuilder.graphics.comSurfaceFactory = () {
            import deltotum.sys.sdl.sdl_surface : SdlSurface;

            return new SdlSurface();
        };

        windowBuilder.isBuilt = true;
        windowBuilder.build(window);

        import deltotum.gui.fonts.bitmap.bitmap_font_generator : BitmapFontGenerator;

        //TODO build and run services after all
        import deltotum.gui.fonts.bitmap.bitmap_font : BitmapFont;

        //TODO from locale\config;
        if (mode == SdlWindowMode.none)
        {
            import deltotum.kit.i18n.langs.alphabets.alphabet_ru : AlphabetRu;
            import deltotum.kit.i18n.langs.alphabets.alphabet_en : AlphabetEn;
            import deltotum.kit.i18n.langs.alphabets.arabic_numerals_alphabet : ArabicNumeralsAlpabet;
            import deltotum.kit.i18n.langs.alphabets.special_characters_alphabet : SpecialCharactersAlphabet;

            auto fontGenerator = new BitmapFontGenerator;
            windowBuilder.build(fontGenerator);
            import deltotum.kit.graphics.colors.rgba : RGBA;

            windowBuilder.asset.defaultBitmapFont = fontGenerator.generate(
                [
                new ArabicNumeralsAlpabet,
                new SpecialCharactersAlphabet,
                new AlphabetEn,
                new AlphabetRu
            ], windowBuilder.asset.defaultFont, theme.colorText);
        }

        import deltotum.kit.scenes.scene_manager : SceneManager;

        auto sceneManager = new SceneManager;
        windowBuilder.build(sceneManager);
        window.scenes = sceneManager;

        debug
        {
            //TODO config, lazy delegate
            import deltotum.gui.supports.guieditor : GuiEditor;
            window.scenes.add(new GuiEditor);
        }

        window.onAfterDestroy = () {
            sceneManager.asset.destroy;
            sceneManager.destroy;
            sdlRenderer.destroy;
        };

        windowManager.add(window);

        return window;
    }

    Window newWindow(
        dstring title = "New window",
        int width = 400,
        int height = 300,
        int x = -1,
        int y = -1,
        Window parent = null)
    {
        return newWindow(title, width, height, x, y, parent, SdlWindowMode.none);
    }

    void clearErrors()
    {
        sdlLib.clearError;
    }

    override void quit()
    {
        clearErrors;

        windowManager.iterateWindows((win) { win.destroy; return true; });

        //TODO auto destroy all services
        _audio.destroy;

        if (joystick !is null)
        {
            joystick.destroy;
        }

        _input.destroy;

        //TODO process EXIT event
        audioMixLib.quit;
        imgLib.quit;

        fontLib.quit;

        sdlLib.quit;
    }

    void updateLoopMs(size_t timestamp)
    {
        SDL_Event event;

        auto mustBeWindow = windowManager.currentWindow;

        if (!mustBeWindow.isNull)
        {
            auto currWindow = mustBeWindow.get;
            //FIXME stop loop after destroy
            if (!currWindow.isDestroyed)
            {
                mustBeWindow.get.scenes.currentScene.timeEventProcessingMs = 0;
            }

        }

        while (isProcessEvents && SDL_PollEvent(&event))
        {
            const startEvent = SDL_GetTicks();
            handleEvent(&event);
            const endEvent = SDL_GetTicks();

            if (!mustBeWindow.isNull)
            {
                auto currWindow = mustBeWindow.get;
                if (!currWindow.isDestroyed)
                {
                    currWindow.scenes.currentScene.timeEventProcessingMs = endEvent - startEvent;
                }

            }
        }
    }

    void updateRender()
    {
        const startStateTime = SDL_GetTicks();
        windowManager.iterateWindows((window) {
            //focus may not be on the window
            if (window.isShowing)
            {
                window.draw;
            }
            return true;
        });

        const endStateTime = SDL_GetTicks();

        auto mustBeWindow = windowManager.currentWindow;

        if (!mustBeWindow.isNull)
        {
            mustBeWindow.get.scenes.currentScene.timeDrawProcessingMs = endStateTime - startStateTime;
        }
    }

    void updateFreqLoopDelta(double delta)
    {
        const startStateTime = SDL_GetTicks();
        windowManager.iterateWindows((window) {
            //focus may not be on the window
            if (window.isShowing)
            {
                window.update(delta);
            }
            return true;
        });

        const endStateTime = SDL_GetTicks();

        auto mustBeWindow = windowManager.currentWindow;

        if (!mustBeWindow.isNull)
        {
            mustBeWindow.get.scenes.currentScene.timeUpdateProcessingMs = endStateTime - startStateTime;
        }
    }

    void handleEvent(SDL_Event* event)
    {
        eventManager.eventProcessor.process(event);

        //Ctrl + C
        if (event.type == SDL_QUIT)
        {
            uint windowId = event.window.windowID;
            if (windowId == 0)
            {
                requestQuit;
                return;
            }

            // closeWindow(windowId);
        }
    }
}
