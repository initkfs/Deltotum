module api.dm.back.sdl2.sdl_application;

// dfmt off
version(SdlBackend):
// dfmt on

import api.core.loggers.logging: Logging;
import api.core.configs.keyvalues.config : Config;
import api.core.contexts.context : Context;
import api.core.apps.app_init_ret : AppInitRet;
import api.core.utils.factories : ProviderFactory;
import api.dm.gui.apps.gui_app : GuiApp;
import api.dm.kit.components.graphics_component : GraphicsComponent;
import api.dm.kit.events.kit_event_manager : KitEventManager;
import api.dm.back.sdl2.sdl_event_processor : SdlEventProcessor;
import api.dm.kit.graphics.graphics : Graphics;
import api.dm.kit.interacts.interact : Interact;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.assets.asset : Asset;
import api.dm.kit.scenes.scene2d : Scene2d;
import api.dm.kit.inputs.keyboards.events.key_event : KeyEvent;
import api.dm.kit.inputs.joysticks.events.joystick_event : JoystickEvent;
import api.dm.back.sdl2.sdl_lib : SdlLib;
import api.dm.back.sdl2.img.sdl_img_lib : SdlImgLib;
import api.dm.back.sdl2.mix.sdl_mix_lib : SdlMixLib;
import api.dm.back.sdl2.ttf.sdl_ttf_lib : SdlTTFLib;
import api.dm.back.sdl2.sdl_window : SdlWindow;
import api.dm.back.sdl2.sdl_window : SdlWindowMode;
import api.dm.back.sdl2.sdl_renderer : SdlRenderer;
import api.dm.back.sdl2.sdl_joystick : SdlJoystick;
import api.dm.kit.windows.events.window_event : WindowEvent;
import api.dm.kit.inputs.pointers.events.pointer_event : PointerEvent;
import api.dm.back.sdl2.sdl_texture : SdlTexture;
import api.dm.back.sdl2.sdl_surface : SdlSurface;
import api.dm.back.sdl2.ttf.sdl_ttf_font : SdlTTFFont;
import api.dm.back.sdl2.img.sdl_image : SdlImage;
import api.dm.com.graphics.com_texture : ComTexture;
import api.dm.com.graphics.com_surface : ComSurface;
import api.dm.com.graphics.com_font : ComFont;
import api.dm.com.graphics.com_image : ComImage;
import api.dm.com.platforms.com_system : ComSystem;

import api.dm.kit.windows.window : Window;
import api.dm.gui.windows.gui_window: GuiWindow;

import api.dm.kit.apps.loops.integrated_loop : IntegratedLoop;
import api.dm.kit.apps.loops.interrupted_loop : InterruptedLoop;
import api.dm.kit.apps.loops.loop : Loop;
import api.dm.kit.windows.window_manager : WindowManager;
import api.dm.kit.apps.caps.cap_graphics : CapGraphics;
import api.dm.kit.events.processing.kit_event_processor : KitEventProcessor;

import std.typecons : Nullable;

import api.dm.kit.media.audio.audio : Audio;
import api.dm.kit.inputs.input : Input;
import api.dm.kit.screens.screen : Screen;

import std.logger : Logger, MultiLogger, FileLogger, LogLevel, sharedLog;
import std.stdio;

import api.dm.sys.cairo.libs : CairoLib;

//import api.dm.sys.chipmunk.libs : ChipmLib;

import bindbc.sdl;
import std.typecons : Nullable;

/**
 * Authors: initkfs
 */
class SdlApplication : GuiApp
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

    SdlEventProcessor eventProcessor;
    bool isScreenSaverEnabled = true;

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

    override AppInitRet initialize(string[] args)
    {
        const initRes = super.initialize(args);
        if (!initRes || initRes.isExit)
        {
            return initRes;
        }

        if (isHeadless)
        {
            import std.process : environment;

            environment["SDL_VIDEODRIVER"] = "dummy";
            uservices.logger.trace("Headless mode enabled");
        }

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

        //https://discourse.libsdl.org/t/graphic-artifacts-when-using-render-scale-quality/20320/3
        //SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "linear");

        imgLib.initialize;
        audioMixLib.initialize;
        fontLib.initialize;

        if (gservices.capGraphics.isJoystick)
        {
            joystick = SdlJoystick.fromDevices;
        }

        initLoop(mainLoop);

        //TODO extract dependency
        import api.dm.back.sdl2.sdl_keyboard : SdlKeyboard;

        auto keyboard = new SdlKeyboard;

        import api.dm.kit.inputs.clipboards.clipboard : Clipboard;
        import api.dm.back.sdl2.sdl_clipboard;

        auto sdlClipboard = new SdlClipboard;
        auto clipboard = new Clipboard(sdlClipboard);

        import api.dm.kit.inputs.cursors.cursor : Cursor;
        import api.dm.back.sdl2.sdl_cursor : SDLCursor;

        Cursor cursor;
        try
        {
            import api.dm.back.sdl2.sdl_cursor : SDLCursor;

            auto sdlCursor = new SDLCursor;
            if (auto err = sdlCursor.createDefault)
            {
                uservices.logger.errorf("Cursor creating error. ", err);
            }
            else
            {
                import api.dm.kit.inputs.cursors.system_cursor : SystemCursor;

                cursor = new SystemCursor(sdlCursor);
                cursor.cursorFactory = () {
                    auto newCursor = new SDLCursor;
                    return newCursor;
                };
            }

        }
        catch (Exception e)
        {
            uservices.logger.warning("Cursor error: ", e);
        }

        if (!cursor)
        {
            import api.dm.kit.inputs.cursors.empty_cursor : EmptyCursor;

            uservices.logger.warning("Create empty cursor");
            cursor = new EmptyCursor;
        }

        _input = new Input(clipboard, cursor);
        _audio = new Audio(audioMixLib);

        //TODO lazy load with config value
        auto cairoLibForLoad = new CairoLib;

        cairoLibForLoad.onAfterLoad = () {
            cairoLib = cairoLibForLoad;

            import KitConfigKeys = api.dm.kit.kit_config_keys;

            if (uservices.config.hasKey(KitConfigKeys.graphicsUseVector))
            {
                const mustBeIsUseVector = uservices.config.getBool(
                    KitConfigKeys.graphicsUseVector);
                if (!mustBeIsUseVector.isNull)
                {
                    const bool isUseVector = mustBeIsUseVector.get;
                    gservices.capGraphics.isVectorGraphics = isUseVector;
                    uservices.logger.trace("Found using vector graphics from config: ", isUseVector);
                }
                else
                {
                    uservices.logger.error("Found using vector graphics key, but not value: ", KitConfigKeys
                            .graphicsUseVector);
                }
            }else {
                gservices.capGraphics.isVectorGraphics = true;
            }

            theme.isUseVectorGraphics = gservices.capGraphics.isVectorGraphics;

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

        sdlLib.enableScreenSaver(isScreenSaverEnabled);
        uservices.logger.trace("Screensaver: ", sdlLib.isScreenSaverEnabled);

        import api.dm.back.sdl2.sdl_screen : SDLScreen;

        auto sdlScreen = new SDLScreen;
        _screen = new Screen(uservices.logging, sdlScreen);

        eventProcessor = new SdlEventProcessor(keyboard);

        eventManager = new KitEventManager;

        eventManager.windowProviderById = (windowId) {
            auto mustBeCurrentWindow = windowManager.byFirstId(windowId);
            if (mustBeCurrentWindow.isNull)
            {
                return Nullable!(Window).init;
            }
            auto currWindow = mustBeCurrentWindow.get;
            if (!currWindow.isShowing || !currWindow.isFocus)
            {
                return Nullable!(Window).init;
            }
            return Nullable!Window(currWindow);
        };

        eventProcessor.onWindow = (ref windowEvent) {
            if (eventManager.onWindow)
            {
                eventManager.onWindow(windowEvent);
            }
            eventManager.dispatchEvent(windowEvent);
        };

        eventProcessor.onPointer = (ref pointerEvent) {
            if (eventManager.onPointer)
            {
                eventManager.onPointer(pointerEvent);
            }
            eventManager.dispatchEvent(pointerEvent);
        };

        eventProcessor.onJoystick = (ref joystickEvent) {
            if (eventManager.onJoystick)
            {
                eventManager.onJoystick(joystickEvent);
            }
            eventManager.dispatchEvent(joystickEvent);
        };

        eventProcessor.onKey = (ref keyEvent) {
            if (eventManager.onKey)
            {
                eventManager.onKey(keyEvent);
            }
            eventManager.dispatchEvent(keyEvent);
        };

        eventProcessor.onTextInput = (ref keyEvent) {
            if (eventManager.onTextInput)
            {
                eventManager.onTextInput(keyEvent);
            }
            eventManager.dispatchEvent(keyEvent);
        };

        eventManager.onKey = (ref key) {
            final switch (key.event) with (KeyEvent.Event)
            {
                case none:
                    break;
                case press:
                    _input.addPressedKey(key.keyName);
                    break;
                case release:
                    _input.addReleasedKey(key.keyName);
                    break;
            }
        };

        eventManager.onJoystick = (ref joystickEvent) {

            if (joystickEvent.event == JoystickEvent.Event.axis)
            {
                if (_input.isJoystickActive)
                {
                    _input.isJoystickChangeAxis = joystickEvent.axis != _input
                        .lastJoystickEvent.axis;
                    _input.isJoystickChangeAxisValue = _input.lastJoystickEvent.axisValue != joystickEvent
                        .axisValue;
                    _input.joystickAxisDelta = joystickEvent.axisValue - _input
                        .lastJoystickEvent.axisValue;
                }
            }
            else if (joystickEvent.event == JoystickEvent.Event.press)
            {
                _input.isJoystickPressed = true;
            }
            else if (joystickEvent.event == JoystickEvent.Event.release)
            {
                _input.isJoystickPressed = false;
            }

            _input.lastJoystickEvent = joystickEvent;
            if (!_input.isJoystickActive)
            {
                _input.isJoystickActive = true;
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
                        if (win.isStopped || win.isPaused)
                        {
                            win.run;
                        }
                        uservices.logger.tracef("Show window '%s' with id %d, state: %s", win.title, win.id, win
                            .state);
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
                            win.pause;
                        }
                        uservices.logger.tracef("Hide window '%s' with id %d, state: %s", win.title, win.id, win
                            .state);
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
                    auto winId = e.ownerId;
                    windowManager.destroyWindowById(winId);
                    if (windowManager.count == 0)
                    {
                        if (windowManager.count == 0 && isQuitOnCloseAllWindows)
                        {
                            uservices.logger.tracef("All windows are closed, exit request");
                            requestExit;
                        }
                    }
                    break;
                default:
                    break;
            }
        };

        windowManager = new WindowManager(uservices.logging);

        return AppInitRet(isExit : false, isInit:
            true);
    }

    override ulong ticks()
    {
        assert(sdlLib);
        return sdlLib.getTicks;
    }

    protected void initLoop(Loop loop)
    {
        loop.onExit = () => exit;
        loop.timestampMsProvider = () => ticks;
        loop.onDelay = () => sdlLib.delay(10);
        loop.onDelayTimeRestMs = (restMs) => sdlLib.delay(cast(uint) restMs);
        loop.onLoopUpdateMs = (timestamp) => updateLoopMs(timestamp);
        loop.onRender = (accumMsRest) => updateRender(accumMsRest);
        loop.onFreqLoopUpdateDelta = (delta) => updateFreqLoopDelta(delta);

        loop.isAutoStart = isAutoStart;
        loop.setUp;
        uservices.logger.tracef("Init loop, autostart: %s, running: %s", loop.isAutoStart, loop
                .isRunning);
    }

    override ComSystem newComSystem()
    {
        import api.dm.back.sdl2.sdl_system : SDLSystem;

        return new SDLSystem;
    }

    SdlRenderer newRenderer(SdlWindow window)
    {
        uint flags;
        if (!isHeadless)
        {
            flags |= SDL_RENDERER_ACCELERATED;
        }
        flags |= SDL_RENDERER_TARGETTEXTURE;
        flags |= SDL_RENDERER_PRESENTVSYNC;
        auto sdlRenderer = new SdlRenderer(window, flags);
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

    ComFont newComFont()
    {
        return new SdlTTFFont;
    }

    ComImage newComImage()
    {
        return new SdlImage;
    }

    void newComImageScoped(scope void delegate(ComImage) onNew)
    {
        scope image = new SdlImage();
        onNew(image);
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

        auto window = new GuiWindow(sdlWindow);
        windowBuilder.window = window;

        if (parent)
        {
            window.window = parent;
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

        //At the stage of initialization and window FactoryKit, not all services can be created
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

        auto asset = createAsset(uservices.logging, uservices.config, uservices.context, () {
            return newComFont;
        });
        assert(asset);
        asset.initialize;
        uservices.logger.trace("Build assets for window: ", window.id);

        windowBuilder.asset = asset;

        theme.defaultMediumFont = asset.font;
        uservices.logger.trace("Set theme font: ", theme.defaultMediumFont.fontPath);

        window.theme = theme;

        import api.dm.kit.graphics.graphics : Graphics;

        //TODO factory method
        windowBuilder.graphics = createGraphics(uservices.logging, sdlRenderer);
        windowBuilder.graphics.initialize;

        windowBuilder.graphics.comTextureProvider = ProviderFactory!ComTexture(
            () => newComTexture(sdlRenderer),
            (dg) => newComTextureScoped(dg, sdlRenderer)
        );

        windowBuilder.graphics.comSurfaceProvider = ProviderFactory!ComSurface(
            &newComSurface,
            &newComSurfaceScoped
        );

        windowBuilder.graphics.comImageProvider = ProviderFactory!ComImage(
            &newComImage,
            &newComImageScoped
        );

        auto interact = new Interact;
        windowBuilder.interact = interact;

        windowBuilder.isBuilt = true;

        //TODO from locale\config;
        if (mode == SdlWindowMode.none)
        {
            import api.dm.kit.assets.fonts.bitmap.bitmap_font_generator : BitmapFontGenerator;

            //TODO build and run services after all
            import api.dm.kit.assets.fonts.bitmap.bitmap_font : BitmapFont;

            auto comSurfProvider = ProviderFactory!ComSurface(
                &newComSurface,
                &newComSurfaceScoped
            );
            auto fontGenerator = newFontGenerator(comSurfProvider);
            windowBuilder.build(fontGenerator);

            import api.dm.kit.graphics.colors.rgba: RGBA;

            const isColorless = isFontTextureIsColorless(uservices.config, uservices.context);

            const colorText = isColorless ? RGBA.white : theme.colorText;
            const colorTextBackground = isColorless ? RGBA.black : theme.colorTextBackground;

            createFontBitmaps(fontGenerator, windowBuilder.asset, colorText, colorTextBackground, (bitmap) {
                // windowBuilder.build(bitmap);
                // bitmap.initialize;
                // assert(bitmap.isInitialized);
                // bitmap.create;
                // assert(bitmap.isCreated);
            });
        }

        import api.dm.kit.factories.image_factory : ImageFactory;
        import api.dm.kit.factories.shape_factory : ShapeFactory;
        import api.dm.kit.factories.texture_factory: TextureFactory;

        ImageFactory imageFactory = new ImageFactory;
        windowBuilder.build(imageFactory);
        ShapeFactory shapeFactory = new ShapeFactory;
        windowBuilder.build(shapeFactory);
        TextureFactory textureFactory = new TextureFactory;
        windowBuilder.build(textureFactory);

        import api.dm.kit.factories.factory_kit : FactoryKit;
        auto factoryKit = new FactoryKit(imageFactory, shapeFactory, textureFactory);
        windowBuilder.build(factoryKit);

        window.factory = factoryKit;

        //Rebuilding window with all services
        windowBuilder.build(window);

        import KitConfigKeys = api.dm.kit.kit_config_keys;

        if (uservices.config.hasKey(KitConfigKeys.sceneIsDebug))
        {
            auto mustBeDebug = uservices.config.getBool(KitConfigKeys.sceneIsDebug);
            if (!mustBeDebug.isNull && mustBeDebug.get)
            {
                import api.dm.gui.supports.editors.guieditor : GuiEditor;

                window.add(new GuiEditor);
            }
        }

        debug
        {
            //TODO config, lazy delegate

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

    override void exit(int code = 0)
    {
        super.exit(code);

        clearErrors;

        if (windowManager)
        {
            windowManager.onWindows((win) {
                if (win.isRunning)
                {
                    win.stop;
                    assert(win.isStopped);
                }
                win.dispose;
                return true;
            });
        }

        if (!joystick.isNull)
        {
            joystick.get.dispose;
        }

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
                mustBeWindow.get.currentScene.timeEventProcessingMs = 0;
            }

        }

        while (isProcessEvents && SDL_PollEvent(&event))
        {
            const startEvent = SDL_GetTicks64();
            handleEvent(&event);
            const endEvent = SDL_GetTicks64();

            if (!mustBeWindow.isNull)
            {
                auto currWindow = mustBeWindow.get;
                if (!currWindow.isDisposed)
                {
                    currWindow.currentScene.timeEventProcessingMs = endEvent - startEvent;
                }

            }
        }
    }

    void updateRender(double accumMsRest)
    {
        const startStateTime = SDL_GetTicks64();
        windowManager.onWindows((window) {
            //focus may not be on the window
            if (window.isShowing)
            {
                window.draw(accumMsRest);
            }
            return true;
        });

        const endStateTime = SDL_GetTicks64();

        auto mustBeWindow = windowManager.current;

        if (!mustBeWindow.isNull)
        {
            mustBeWindow.get.currentScene.timeDrawProcessingMs = endStateTime - startStateTime;
        }
    }

    void updateFreqLoopDelta(double delta)
    {
        const startStateTime = SDL_GetTicks64();
        windowManager.onWindows((window) {
            //focus may not be on the window
            if (window.isShowing)
            {
                window.update(delta);
            }
            return true;
        });

        const endStateTime = SDL_GetTicks64();

        auto mustBeWindow = windowManager.current;

        if (!mustBeWindow.isNull)
        {
            mustBeWindow.get.currentScene.timeUpdateProcessingMs = endStateTime - startStateTime;
        }
    }

    void handleEvent(SDL_Event* event)
    {
        eventProcessor.process(event);

        //Ctrl + C
        if (event.type == SDL_QUIT)
        {
            windowManager.destroyAll;
            requestExit;
        }
    }
}
