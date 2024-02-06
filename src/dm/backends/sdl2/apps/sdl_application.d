module dm.backends.sdl2.apps.sdl_application;

// dfmt off
version(SdlBackend):
// dfmt on

import dm.core.configs.config : Config;
import dm.core.contexts.context : Context;
import dm.core.apps.application_exit : ApplicationExit;
import dm.core.utils.provider : Provider;
import dm.kit.apps.continuously_application : ContinuouslyApplication;
import dm.kit.apps.comps.graphics_component : GraphicsComponent;
import dm.kit.events.event_manager : EventManager;
import dm.backends.sdl2.events.sdl_event_processor : SdlEventProcessor;
import dm.kit.scenes.scene_manager : SceneManager;
import dm.kit.graphics.graphics : Graphics;
import dm.kit.interacts.interact : Interact;
import dm.kit.sprites.sprite : Sprite;
import dm.kit.assets.asset : Asset;
import dm.kit.scenes.scene : Scene;
import dm.kit.inputs.keyboards.events.key_event : KeyEvent;
import dm.kit.inputs.joysticks.events.joystick_event : JoystickEvent;
import dm.backends.sdl2.sdl_lib : SdlLib;
import dm.backends.sdl2.img.sdl_img_lib : SdlImgLib;
import dm.backends.sdl2.mix.sdl_mix_lib : SdlMixLib;
import dm.backends.sdl2.ttf.sdl_ttf_lib : SdlTTFLib;
import dm.backends.sdl2.sdl_window : SdlWindow;
import dm.backends.sdl2.sdl_window : SdlWindowMode;
import dm.backends.sdl2.sdl_renderer : SdlRenderer;
import dm.backends.sdl2.sdl_joystick : SdlJoystick;
import dm.kit.windows.events.window_event : WindowEvent;
import dm.kit.inputs.pointers.events.pointer_event : PointerEvent;
import dm.backends.sdl2.sdl_texture : SdlTexture;
import dm.backends.sdl2.sdl_surface : SdlSurface;
import dm.backends.sdl2.ttf.sdl_ttf_font : SdlTTFFont;
import dm.backends.sdl2.img.sdl_image : SdlImage;
import dm.com.graphics.com_texture : ComTexture;
import dm.com.graphics.com_surface : ComSurface;
import dm.com.graphics.com_font : ComFont;
import dm.com.graphics.com_image : ComImage;
import dm.kit.timers.timer : Timer;

import dm.kit.windows.window : Window;

import dm.kit.apps.loops.integrated_loop : IntegratedLoop;
import dm.kit.apps.loops.interrupted_loop : InterruptedLoop;
import dm.kit.apps.loops.loop : Loop;
import dm.kit.windows.window_manager : WindowManager;
import dm.kit.apps.caps.cap_graphics : CapGraphics;
import dm.kit.events.processing.kit_event_processor : KitEventProcessor;

import std.typecons : Nullable;

import dm.media.audio.audio : Audio;
import dm.kit.inputs.input : Input;
import dm.kit.screens.screen : Screen;

import std.logger : Logger, MultiLogger, FileLogger, LogLevel, sharedLog;
import std.stdio;

import dm.sys.cairo.libs : CairoLib;

//import dm.sys.chipmunk.libs : ChipmLib;

import bindbc.sdl;
import std.typecons : Nullable;

/**
 * Authors: initkfs
 */
class SdlApplication : ContinuouslyApplication
{
    uint delegate(uint flags) onSdlInitFlags;
    private
    {
        SdlLib sdlLib;
        SdlMixLib audioMixLib;
        SdlImgLib imgLib;
        SdlTTFLib fontLib;
        Nullable!SdlJoystick joystick;

        CairoLib cairoLib;
        //ChipmLib chipmLib;
    }

    EventManager!(SDL_Event*) eventManager;

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

        profile("Start SDL backend");

        initLoop(mainLoop);

        uint flags;
        if (isVideoEnabled)
        {
            flags |= SDL_INIT_VIDEO;
            gservices.capGraphics.isVideo = true;
        }

        if (isAudioEnabled)
        {
            flags |= SDL_INIT_AUDIO;
            gservices.capGraphics.isAudio = true;
        }

        if (isTimerEnabled)
        {
            flags |= SDL_INIT_TIMER;
            gservices.capGraphics.isTimer = true;
        }

        if (isJoystickEnabled)
        {
            flags |= SDL_INIT_JOYSTICK;
            gservices.capGraphics.isJoystick = true;
        }

        if (onSdlInitFlags)
        {
            flags = onSdlInitFlags(flags);
        }

        sdlLib.initialize(flags);
        uservices.logger.trace("SDL ", sdlLib.getSdlVersionInfo);
        profile("SDL loaded");

        //TODO move to hal layer
        SDL_LogSetPriority(SDL_LOG_CATEGORY_APPLICATION, SDL_LOG_PRIORITY_WARN);

        imgLib.initialize;
        profile("Image libs loaded");

        audioMixLib.initialize;
        profile("Audio libs loaded");

        fontLib.initialize;
        profile("Font libs loaded");

        if (gservices.capGraphics.isJoystick)
        {
            joystick = SdlJoystick.fromDevices;
            uservices.logger.trace("Init joystick");
        }

        //TODO extract dependency
        import dm.backends.sdl2.sdl_keyboard : SdlKeyboard;

        auto keyboard = new SdlKeyboard;

        import dm.kit.inputs.clipboards.clipboard : Clipboard;
        import dm.backends.sdl2.sdl_clipboard;

        auto sdlClipboard = new SdlClipboard;
        auto clipboard = new Clipboard(sdlClipboard);

        import dm.kit.inputs.cursors.system_cursor : SystemCursor;
        import dm.backends.sdl2.sdl_cursor : SDLCursor;

        SystemCursor cursor;
        try
        {
            import dm.backends.sdl2.sdl_cursor : SDLCursor;

            auto sdlCursor = new SDLCursor;
            if (auto err = sdlCursor.fromDefaultCursor)
            {
                uservices.logger.errorf("Cursor creating error. ", err);
            }
            else
            {
                cursor = new SystemCursor(sdlCursor);
                cursor.cursorFactory = (type) {
                    auto newCursor = new SDLCursor(type);
                    return newCursor;
                };
            }

        }
        catch (Exception e)
        {
            uservices.logger.warningf("Cursor error: %s", e);
            cursor = new SystemCursor(null);
        }

        _timer = newTimer;

        _input = new Input(clipboard, cursor);
        _audio = new Audio(audioMixLib);

        profile("Graphics services loaded");

        auto cairoLibForLoad = new CairoLib;

        cairoLibForLoad.onAfterLoad = () {
            cairoLib = cairoLibForLoad;
            gservices.capGraphics.isVectorGraphics = true;
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

        profile("Cairo loaded");

        //Physics
        // auto physLibForLoad = new ChipmLib;

        // physLibForLoad.onAfterLoad = () {
        //     chipmLib = physLibForLoad;
        //     _cap.isPhysics = true;
        //     uservices.logger.trace("Load Chipmunk library.");
        // };

        // physLibForLoad.onNoLibrary = () => uservices.logger.error("Chipmunk library loading error.");
        // physLibForLoad.onBadLibrary = () => uservices.logger.error("Chipmunk bad library.");
        // physLibForLoad.onErrorWithMessage = (err, msg) {
        //     import std.string : fromStringz;

        //     uservices.logger.errorf("Chipmunk loading error. %s: %s\n", err.fromStringz.idup, msg
        //             .fromStringz.idup);
        //     physLibForLoad.unload;
        //     physLibForLoad = null;
        // };

        // physLibForLoad.load;

        import dm.backends.sdl2.sdl_screen : SDLScreen;

        auto sdlScreen = new SDLScreen;
        _screen = new Screen(uservices.logger, sdlScreen);

        auto processor = new SdlEventProcessor(keyboard);
        eventManager = new EventManager!(SDL_Event*)(processor);
        eventManager.targetsProvider = (windowId) {
            auto mustBeCurrentWindow = windowManager.byFirstId(windowId);
            if (mustBeCurrentWindow.isNull)
            {
                return Nullable!(Sprite[]).init;
            }
            auto currWindow = mustBeCurrentWindow.get;
            if (!currWindow.isShowing || !currWindow.isFocus)
            {
                return Nullable!(Sprite[]).init;
            }
            auto targets = currWindow.scenes.currentScene.activeSprites;
            return Nullable!(Sprite[])(targets);
        };

        eventManager.onKey = (ref key) {
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

        eventManager.onJoystick = (ref joystickEvent) {

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

        eventManager.onWindow = (ref e) {
            switch (e.event) with (WindowEvent.Event)
            {
                case focusIn:
                    windowManager.onWindowsById(e.ownerId, (win) {
                        win.isFocus = true;
                        e.isConsumed = true;
                        uservices.logger.tracef("Window focus on window '%s' with id %d", win.title, win
                            .id);
                        return true;
                    });
                    break;
                case focusOut:
                    windowManager.onWindowsById(e.ownerId, (win) {
                        win.isFocus = false;
                        e.isConsumed = true;
                        uservices.logger.tracef("Window focus out on window '%s' with id %d", win.title, win
                            .id);
                        return true;
                    });
                    break;
                case show:
                    windowManager.onWindowsById(e.ownerId, (win) {
                        win.isShowing = true;
                        e.isConsumed = true;
                        if (win.onShow.length > 0)
                        {
                            foreach (dg; win.onShow)
                            {
                                dg();
                            }
                        }
                        if (win.isStopped)
                        {
                            win.run;
                        }
                        uservices.logger.tracef("Show window '%s' with id %d", win.title, win.id);
                        return true;
                    });
                    break;
                case hide:
                    windowManager.onWindowsById(e.ownerId, (win) {
                        win.isShowing = false;
                        if (win.onHide.length > 0)
                        {
                            foreach (dg; win.onHide)
                            {
                                dg();
                            }
                        }
                        if (win.isRunning)
                        {
                            win.stop;
                        }
                        uservices.logger.tracef("Hide window '%s' with id %d", win.title, win.id);
                        return true;
                    });
                    break;
                case resize:
                    windowManager.onWindowsById(e.ownerId, (win) {
                        win.confirmResize(e.width, e.height);
                        e.isConsumed = true;
                        return true;
                    });
                    break;
                case minimize:
                    windowManager.onWindowsById(e.ownerId, (win) {
                        if (win.onMinimize.length > 0)
                        {
                            foreach (dg; win.onMinimize)
                            {
                                dg();
                            }
                        }
                        uservices.logger.tracef("Minimize window '%s' with id %d", win.title, win
                            .id);
                        return true;
                    });
                    break;
                case maximize:
                    windowManager.onWindowsById(e.ownerId, (win) {
                        if (win.onMaximize.length > 0)
                        {
                            foreach (dg; win.onMaximize)
                            {
                                dg();
                            }
                        }
                        uservices.logger.tracef("Maximize window '%s' with id %d", win.title, win
                            .id);
                        return true;
                    });
                    break;
                case close:
                    windowManager.onWindowsById(e.ownerId, (win) {
                        if (win.onClose.length > 0)
                        {
                            foreach (dg; win.onClose)
                            {
                                dg();
                            }
                        }
                        return true;
                    });
                    destroyWindow(e.ownerId);
                    break;
                default:
                    break;
            }
        };

        eventManager.onPointer = (ref mouseEvent) {
            if (mouseEvent.event == PointerEvent.Event.down)
            {
                auto mustBeWindow = windowManager.current;
                if (mustBeWindow.isNull)
                {
                    return;
                }
                auto window = mustBeWindow.get;
                foreach (obj; window.scenes.currentScene.activeSprites)
                {
                    if (obj.bounds.contains(mouseEvent.x, mouseEvent.y))
                    {
                        if (!obj.isFocus)
                        {
                            obj.isFocus = true;
                        }

                        import dm.kit.sprites.events.focus.focus_event : FocusEvent;

                        auto focusEvent = FocusEvent(FocusEvent.Event.focusIn, mouseEvent
                                .ownerId, mouseEvent.x, mouseEvent.y);
                        eventManager.dispatchEvent(focusEvent, obj);

                        //for children
                        auto focusOutEvent = FocusEvent(FocusEvent.Event.focusOut, mouseEvent
                                .ownerId, mouseEvent.x, mouseEvent.y);
                        eventManager.dispatchEvent(focusOutEvent, obj);
                    }
                    else
                    {
                        if (obj.isFocus)
                        {
                            obj.isFocus = false;
                            import dm.kit.sprites.events.focus.focus_event : FocusEvent;

                            auto focusEvent = FocusEvent(FocusEvent.Event.focusOut, mouseEvent
                                    .ownerId, mouseEvent.x, mouseEvent.y);
                            eventManager.dispatchEvent(focusEvent, obj);
                        }
                    }
                }
            }
        };

        windowManager = new WindowManager(uservices.logger);

        eventManager.startEvents;

        profile("SDL backends end");

        return ApplicationExit(false);
    }

    protected void initLoop(Loop loop)
    {
        loop.onQuit = () => quit;
        loop.timestampMsProvider = () => sdlLib.getTicks;
        loop.onDelay = () => sdlLib.delay(20);
        loop.onLoopUpdateMs = (timestamp) => updateLoopMs(timestamp);
        loop.onRender = (accumMsRest) => updateRender(accumMsRest);
        loop.onFreqLoopUpdateDelta = (delta) => updateFreqLoopDelta(delta);

        loop.isAutoStart = isAutoStart;
        loop.setUp;
        uservices.logger.tracef("Init loop, autostart: %s, running: %s", loop.isAutoStart, loop
                .isRunning);
    }

    SdlRenderer newRenderer(SdlWindow window)
    {
        auto sdlRenderer = new SdlRenderer(window, SDL_RENDERER_ACCELERATED | SDL_RENDERER_TARGETTEXTURE | SDL_RENDERER_PRESENTVSYNC);
        return sdlRenderer;
    }

    ComTexture newComTexture(SdlRenderer renderer)
    {
        return new SdlTexture(renderer);
    }

    void newComTextureScoped(scope void delegate(ComTexture) onNew, SdlRenderer renderer)
    {
        scope surf = new SdlTexture(renderer);
        onNew(surf);
    }

    ComSurface newComSurface()
    {
        return new SdlSurface;
    }

    void newComSurfaceScoped(scope void delegate(ComSurface) onNew)
    {
        scope surf = new SdlSurface;
        onNew(surf);
    }

    ComFont newComFont(string path, int size)
    {
        return new SdlTTFFont(path, size);
    }

    ComImage newComImage()
    {
        return new SdlImage();
    }

    void newComImageScoped(scope void delegate(ComImage) onNew)
    {
        scope image = new SdlImage();
        onNew(image);
    }

    Timer newTimer()
    {
        Timer t = new Timer(uservices.logger);
        t.tickProvider = () { return SDL_GetTicks(); };
        return t;
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
        import std.conv : to;

        auto sdlWindow = new SdlWindow;
        sdlWindow.mode = mode;

        auto windowBuilder = newWindowServices;
        buildPartially(windowBuilder);

        auto window = new Window(sdlWindow);
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

        //At the stage of initialization and window creation, not all services can be created
        buildPartially(window);

        window.initialize;
        window.create;

        window.setNormalWindow;

        window.resize(width, height);

        const int newX = (x == -1) ? SDL_WINDOWPOS_UNDEFINED : x;
        const int newY = (y == -1) ? SDL_WINDOWPOS_UNDEFINED : y;

        window.pos(newX, newY);

        SdlRenderer sdlRenderer = newRenderer(sdlWindow);
        window.renderer = sdlRenderer;

        window.title = title;

        auto asset = createAsset(uservices.logger, uservices.config, uservices.context, (path, size) {
            return newComFont(path, size);
        });
        assert(asset);
        asset.initialize;

        windowBuilder.asset = asset;

        auto theme = createTheme(uservices.logger, uservices.config, uservices.context, asset);

        import dm.kit.graphics.graphics : Graphics;

        //TODO factory method
        windowBuilder.graphics = createGraphics(uservices.logger, sdlRenderer, theme);
        windowBuilder.graphics.initialize;

        windowBuilder.graphics.comTextureProvider = Provider!ComTexture(
            () => newComTexture(sdlRenderer),
            (dg) => newComTextureScoped(dg, sdlRenderer)
        );

        windowBuilder.graphics.comSurfaceProvider = Provider!ComSurface(
            &newComSurface,
            &newComSurfaceScoped
        );

        windowBuilder.graphics.comImageProvider = Provider!ComImage(
            &newComImage,
            &newComImageScoped
        );

        windowBuilder.isBuilt = true;

        //TODO from locale\config;
        if (mode == SdlWindowMode.none)
        {
            import dm.kit.assets.fonts.bitmap.bitmap_font_generator : BitmapFontGenerator;

            //TODO build and run services after all
            import dm.kit.assets.fonts.bitmap.bitmap_font : BitmapFont;

            auto comSurfProvider = Provider!ComSurface(
                    &newComSurface,
                    &newComSurfaceScoped
            );
            auto fontGenerator = newFontGenerator(comSurfProvider);
            windowBuilder.build(fontGenerator);

            windowBuilder.asset.fontBitmap = createFontBitmap(fontGenerator, asset, theme);
            windowBuilder.asset.fontBitmap.initialize;

            auto colorText = theme.colorText;

            auto themeFont = windowBuilder.asset.fontBitmap.copy;
            themeFont.color = colorText;
            windowBuilder.asset.addCachedFont(colorText, themeFont);
        }

        import dm.kit.scenes.scene_manager : SceneManager;

        auto sceneManager = newSceneManager(uservices.logger, uservices.config, uservices.context);
        windowBuilder.build(sceneManager);
        sceneManager.initialize;
        sceneManager.create;

        window.scenes = sceneManager;

        //Rebuilding window with all services
        windowBuilder.build(window);

        debug
        {
            //TODO config, lazy delegate
            import dm.gui.supports.editors.guieditor : GuiEditor;

            window.scenes.addCreate(new GuiEditor);
        }

        window.onAfterDestroy ~= () {
            //TODO who should manage the assets?
            window.asset.dispose;
            window.graphics.dispose;
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

        if (windowManager)
        {
            windowManager.onWindows((win) { win.dispose; return true; });
        }

        //TODO auto destroy all services
        _audio.dispose;

        if (!joystick.isNull)
        {
            joystick.get.dispose;
        }

        _input.dispose;

        //TODO process EXIT event
        audioMixLib.quit;
        imgLib.quit;

        fontLib.quit;

        sdlLib.quit;
    }

    void updateLoopMs(size_t timestamp)
    {
        SDL_Event event;

        auto mustBeWindow = windowManager.current;

        if (!mustBeWindow.isNull)
        {
            auto currWindow = mustBeWindow.get;
            //FIXME stop loop after destroy
            if (!currWindow.isDisposed)
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
                if (!currWindow.isDisposed)
                {
                    currWindow.scenes.currentScene.timeEventProcessingMs = endEvent - startEvent;
                }

            }
        }
    }

    void updateRender(double accumMsRest)
    {
        const startStateTime = SDL_GetTicks();
        windowManager.onWindows((window) {
            //focus may not be on the window
            if (window.isShowing)
            {
                window.draw(accumMsRest);
            }
            return true;
        });

        const endStateTime = SDL_GetTicks();

        auto mustBeWindow = windowManager.current;

        if (!mustBeWindow.isNull)
        {
            mustBeWindow.get.scenes.currentScene.timeDrawProcessingMs = endStateTime - startStateTime;
        }
    }

    void updateFreqLoopDelta(double delta)
    {
        const startStateTime = SDL_GetTicks();
        windowManager.onWindows((window) {
            //focus may not be on the window
            if (window.isShowing)
            {
                window.update(delta);
            }
            return true;
        });

        const endStateTime = SDL_GetTicks();

        auto mustBeWindow = windowManager.current;

        if (!mustBeWindow.isNull)
        {
            mustBeWindow.get.scenes.currentScene.timeUpdateProcessingMs = endStateTime - startStateTime;
        }
    }

    void handleEvent(SDL_Event* event)
    {
        eventManager.process(event);

        //Ctrl + C
        if (event.type == SDL_QUIT)
        {
            uint windowId = event.window.windowID;
            destroyWindow(windowId);

            requestQuit;
        }
    }
}
