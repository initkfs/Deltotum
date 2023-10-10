module deltotum.kit.apps.sdl_application;

// dfmt off
version(SdlBackend):
// dfmt on

import deltotum.core.configs.config : Config;
import deltotum.core.contexts.context : Context;
import deltotum.core.apps.application_exit : ApplicationExit;
import deltotum.kit.apps.continuously_application : ContinuouslyApplication;
import deltotum.kit.apps.comps.graphics_component : GraphicsComponent;
import deltotum.kit.events.event_manager : EventManager;
import deltotum.sys.sdl.events.sdl_event_processor : SdlEventProcessor;
import deltotum.kit.scenes.scene_manager : SceneManager;
import deltotum.kit.graphics.graphics : Graphics;
import deltotum.kit.interacts.interact : Interact;
import deltotum.kit.sprites.sprite : Sprite;
import deltotum.kit.assets.asset : Asset;
import deltotum.kit.scenes.scene : Scene;
import deltotum.kit.inputs.keyboards.events.key_event : KeyEvent;
import deltotum.kit.inputs.joysticks.events.joystick_event : JoystickEvent;
import deltotum.core.extensions.extension : Extension;
import deltotum.sys.sdl.sdl_lib : SdlLib;
import deltotum.sys.sdl.img.sdl_img_lib : SdlImgLib;
import deltotum.sys.sdl.mix.sdl_mix_lib : SdlMixLib;
import deltotum.sys.sdl.ttf.sdl_ttf_lib : SdlTTFLib;
import deltotum.sys.sdl.sdl_window : SdlWindow;
import deltotum.sys.sdl.sdl_window : SdlWindowMode;
import deltotum.sys.sdl.sdl_renderer : SdlRenderer;
import deltotum.sys.sdl.sdl_joystick : SdlJoystick;
import deltotum.kit.windows.events.window_event : WindowEvent;
import deltotum.kit.inputs.pointers.events.pointer_event : PointerEvent;
import deltotum.sys.sdl.sdl_texture : SdlTexture;
import deltotum.sys.sdl.sdl_surface : SdlSurface;

import deltotum.kit.windows.window : Window;

import deltotum.kit.apps.loops.integrated_loop : IntegratedLoop;
import deltotum.kit.apps.loops.interrupted_loop : InterruptedLoop;
import deltotum.kit.apps.loops.loop : Loop;
import deltotum.kit.windows.window_manager : WindowManager;
import deltotum.kit.apps.caps.cap_graphics : CapGraphics;

import std.typecons : Nullable;

import deltotum.media.audio.audio : Audio;
import deltotum.kit.inputs.input : Input;
import deltotum.kit.screens.screen : Screen;

import std.logger : Logger, MultiLogger, FileLogger, LogLevel, sharedLog;
import std.stdio;

import deltotum.sys.cairo.libs : CairoLib;

//import deltotum.sys.chipmunk.libs : ChipmLib;

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

        //TODO move to hal layer
        SDL_LogSetPriority(SDL_LOG_CATEGORY_APPLICATION, SDL_LOG_PRIORITY_WARN);

        imgLib.initialize;
        audioMixLib.initialize;
        fontLib.initialize;

        if (gservices.capGraphics.isJoystick)
        {
            joystick = SdlJoystick.fromDevices;
            uservices.logger.trace("Init joystick");
        }

        //TODO extract dependency
        import deltotum.sys.sdl.sdl_keyboard : SdlKeyboard;

        auto keyboard = new SdlKeyboard;

        import deltotum.kit.inputs.clipboards.clipboard : Clipboard;
        import deltotum.sys.sdl.sdl_clipboard;

        auto sdlClipboard = new SdlClipboard;
        auto clipboard = new Clipboard(sdlClipboard);

        import deltotum.kit.inputs.cursors.system_cursor : SystemCursor;
        import deltotum.sys.sdl.sdl_cursor : SDLCursor;

        SystemCursor cursor;
        try
        {
            cursor = new SystemCursor;
            cursor.cursorFactory = (type) {
                auto newCursor = new SDLCursor(type);
                return newCursor;
            };
        }
        catch (Exception e)
        {
            uservices.logger.warningf("Cursor error: %s", e);
            cursor = new SystemCursor(null);
        }

        _input = new Input(clipboard, cursor);
        _audio = new Audio(audioMixLib);

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

        import deltotum.sys.sdl.sdl_screen : SDLScreen;

        auto sdlScreen = new SDLScreen;
        _screen = new Screen(uservices.logger, sdlScreen);

        eventManager = new EventManager();
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

        eventManager.eventProcessor = new SdlEventProcessor(keyboard);
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

        windowManager = new WindowManager(uservices.logger);

        eventManager.startEvents;

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

    SdlTexture newTexture(SdlRenderer renderer)
    {
        return new SdlTexture(renderer);
    }

    SdlSurface newSurface()
    {
        return new SdlSurface();
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

        auto asset = createAsset(uservices.logger, uservices.config, uservices.context);
        assert(asset);
        windowBuilder.asset = asset;

        auto theme = createTheme(uservices.logger, uservices.config, uservices.context, asset);

        import deltotum.kit.graphics.graphics : Graphics;

        //TODO factory method
        windowBuilder.graphics = createGraphics(uservices.logger, sdlRenderer, theme);
        windowBuilder.graphics.comTextureFactory = () {
            return newTexture(sdlRenderer);
        };

        windowBuilder.graphics.comSurfaceFactory = () { return newSurface; };

        windowBuilder.isBuilt = true;

        //TODO from locale\config;
        if (mode == SdlWindowMode.none)
        {
            import deltotum.gui.fonts.bitmap.bitmap_font_generator : BitmapFontGenerator;

            //TODO build and run services after all
            import deltotum.gui.fonts.bitmap.bitmap_font : BitmapFont;

            auto fontGenerator = newFontGenerator;
            windowBuilder.build(fontGenerator);

            auto fontBitmap = createFontBitmap(fontGenerator, asset, theme);
            windowBuilder.asset.fontBitmap = fontBitmap;

            auto colorText = theme.colorText;

            auto themeFont = windowBuilder.asset.fontBitmap.copy;
            themeFont.setColor(colorText);
            windowBuilder.asset.addCachedFont(colorText, themeFont);
        }

        import deltotum.kit.scenes.scene_manager : SceneManager;

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
            import deltotum.gui.supports.editors.guieditor : GuiEditor;

            window.scenes.addCreate(new GuiEditor);
        }

        window.onAfterDestroy ~= () {
            //TODO who should manage the assets?
            window.asset.destroy;
            window.graphics.destroy;
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
            windowManager.onWindows((win) { win.destroy; return true; });
        }

        //TODO auto destroy all services
        _audio.destroy;

        if (!joystick.isNull)
        {
            joystick.get.destroy;
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

        auto mustBeWindow = windowManager.current;

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
        eventManager.eventProcessor.process(event);

        //Ctrl + C
        if (event.type == SDL_QUIT)
        {
            uint windowId = event.window.windowID;
            destroyWindow(windowId);

            requestQuit;
        }
    }
}
