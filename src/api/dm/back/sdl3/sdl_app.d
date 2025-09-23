module api.dm.back.sdl3.sdl_app;

import api.dm.com.graphic.com_screen;

import api.dm.com.com_result : ComResult;
import api.core.loggers.logging : Logging;
import api.core.configs.keyvalues.config : Config;
import api.core.contexts.context : Context;
import api.core.apps.app_result : AppResult;
import api.core.utils.factories : ProviderFactory;
import api.dm.gui.apps.gui_app : GuiApp;
import api.dm.kit.components.graphic_component : GraphicComponent;
import api.dm.kit.events.kit_event_manager : KitEventManager;
import api.dm.back.sdl3.sdl_event_processor : SdlEventProcessor;
import api.dm.kit.graphics.graphic : Graphic;
import api.dm.gui.interacts.interact : Interact;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.assets.asset : Asset;
import api.dm.back.sdl3.sdl_screen : SDLScreen;
import api.dm.kit.scenes.scene2d : Scene2d;
import api.dm.kit.inputs.keyboards.events.key_event : KeyEvent;
import api.dm.kit.inputs.joysticks.events.joystick_event : JoystickEvent;
import api.dm.back.sdl3.sdl_lib : SdlLib;
import api.dm.back.sdl3.mixers.sdl_mixer_lib : SdlMixerLib;
import api.dm.com.audio.com_audio_device;
import api.dm.back.sdl3.sounds.sdl_audio_device : SdlAudioDevice;
import api.dm.back.sdl3.fonts.sdl_ttf_lib : SdlTTFLib;
import api.dm.back.sdl3.sdl_window : SdlWindow;
import api.dm.back.sdl3.sdl_window : SdlWindowMode;
import api.dm.back.sdl3.sdl_renderer : SdlRenderer;
import api.dm.kit.inputs.keyboards.keyboard : Keyboard;
import api.dm.kit.screens.single_screen : SingleScreen;

import api.dm.back.sdl3.joystick.sdl_joystick_lib : SdlJoystickLib;
import api.dm.back.sdl3.joystick.sdl_joystick : SdlJoystick;
import api.dm.kit.windows.events.window_event : WindowEvent;
import api.dm.kit.inputs.pointers.events.pointer_event : PointerEvent;
import api.dm.back.sdl3.sdl_texture : SdlTexture;
import api.dm.back.sdl3.sdl_surface : SdlSurface;
import api.dm.back.sdl3.fonts.sdl_ttf_font : SdlTTFFont;
import api.dm.back.sdl3.images.sdl_image : SdlImage;
import api.dm.back.sdl3.mixers.sdl_mixer_chunk : SdlMixerChunk;
import api.dm.com.graphic.com_texture : ComTexture;
import api.dm.com.graphic.com_surface : ComSurface;
import api.dm.com.graphic.com_screen : ComScreenId;
import api.dm.com.graphic.com_font : ComFont;
import api.dm.com.graphic.com_image : ComImage;
import api.dm.com.platforms.com_platform : ComPlatform;

import api.dm.kit.windows.window : Window;
import api.dm.gui.windows.gui_window : GuiWindow;

import api.dm.kit.apps.loops.integrated_loop : IntegratedLoop;
import api.dm.kit.apps.loops.interrupted_loop : InterruptedLoop;
import api.dm.kit.apps.loops.loop : Loop;
import api.dm.kit.platforms.caps.cap_graphics : CapGraphics;
import api.dm.kit.events.processing.kit_event_processor : KitEventProcessor;

import std.typecons : Nullable;

import api.dm.kit.media.multimedia : MultiMedia;
import api.dm.kit.media.audio.mixers.audio_mixer : AudioMixer;
import api.dm.kit.inputs.input : Input;
import api.dm.kit.platforms.screens.screening : Screening;

import std.logger : Logger, MultiLogger, FileLogger, LogLevel, sharedLog;
import std.stdio;

import api.dm.lib.cairo : CairoLib;
import api.dm.lib.libxml.native : LibxmlLib;

//import api.dm.lib.chipmunk.libs : ChipmLib;

import api.dm.back.sdl3.externs.csdl3;
import std.typecons : Nullable;
import api.dm.back.sdl3.gpu.gpu_device;

/**
 * Authors: initkfs
 */
class SdlApp : GuiApp
{
    uint delegate(uint flags) onCreatedInitFlags;
    void delegate() onCreatedSystems;
    void delegate() onInitializedSystems;

    private
    {
        SdlLib sdlLib;

        SdlTTFLib sdlFont;

        Nullable!SdlAudioDevice audioOut;
        Nullable!SdlMixerLib sdlAudioMixer;
        Nullable!SdlJoystickLib sdlJoystick;

        Nullable!SdlJoystick sdlCurrentJoystick;

        CairoLib cairoLib;
        LibxmlLib libxmlLib;

        SDLScreen comScreen;

        SdlGPUDevice gpuDevice;
    }

    protected
    {
        string name;
        string id;
    }

    SdlEventProcessor eventProcessor;
    bool isScreenSaverEnabled = true;

    this(string name, string id = null, Loop loop = null)
    {
        super(loop ? loop : newMainLoop);

        this.name = name;
        this.id = id.length > 0 ? id : name;
    }

    override AppResult initialize(string[] args)
    {
        const initRes = super.initialize(args);
        if (!initRes.isInit || initRes.isExit)
        {
            return initRes;
        }

        uservices.logger.trace("Graphic app initialized, starting backend");

        if (isHeadless)
        {
            import std.process : environment;

            environment["SDL_VIDEODRIVER"] = "dummy";
            uservices.logger.trace("Headless mode enabled");
        }

        uint flags = 0;

        flags |= SDL_INIT_VIDEO;
        uservices.logger.trace("Video enabled");

        if (isAudioEnabled)
        {
            flags |= SDL_INIT_AUDIO;
            gservices.platform.cap.isAudio = true;
            uservices.logger.trace("Audio enabled");
        }

        if (isJoystickEnabled)
        {
            flags |= SDL_INIT_JOYSTICK;
            gservices.platform.cap.isJoystick = true;
            uservices.logger.trace("Joystick enabled");
        }

        if (onCreatedInitFlags)
        {
            flags = onCreatedInitFlags(flags);
        }

        if (const err = createSystems(gservices.platform.cap))
        {
            uservices.logger.errorf("SDL systems creation error: " ~ err.toString);
            return initRes;
        }

        uservices.logger.trace("SDL systems created");

        if (onCreatedSystems)
        {
            onCreatedSystems();
        }

        if (const err = initializeSystems(flags, gservices.platform.cap))
        {
            uservices.logger.errorf("SDL systems initialization error: " ~ err.toString);
            return initRes;
        }

        //TODO move to systems
        import KitConfigKeys = api.dm.kit.kit_config_keys;

        gpuDevice = new SdlGPUDevice;
        if (uservices.config.getBool(KitConfigKeys.backendIsGPU))
        {
            if (const err = gpuDevice.create)
            {
                throw new Exception(err.toString);
            }
            string gpuName;
            if (const err = gpuDevice.getDriverNameNew(gpuName))
            {
                uservices.logger.trace("Error reading GPU driver name: ", err.toString);
            }
            else
            {
                uservices.logger.trace("Create GPU device: ", gpuName);
            }
        }

        uservices.logger.trace("SDL systems initialized");

        if (onInitializedSystems)
        {
            onInitializedSystems();
        }

        assert(mainLoop);
        initLoop(mainLoop);

        //TODO extract dependency
        import api.dm.back.sdl3.sdl_keyboard : SdlKeyboard;

        auto sdlKeyboard = new SdlKeyboard;

        auto keyboard = new Keyboard(sdlKeyboard);

        import api.dm.kit.inputs.clipboards.clipboard : Clipboard;
        import api.dm.back.sdl3.sdl_clipboard;

        auto sdlClipboard = new SdlClipboard;
        auto clipboard = new Clipboard(sdlClipboard, uservices.logging);

        import api.dm.kit.inputs.cursors.cursor : Cursor;
        import api.dm.back.sdl3.sdl_cursor : SDLCursor;

        Cursor cursor;
        try
        {
            import api.dm.back.sdl3.sdl_cursor : SDLCursor;

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

        _input = new Input(uservices.logging, keyboard, clipboard, cursor);

        auto audioClip = new AudioMixer(sdlAudioMixer.get);

        _media = new MultiMedia(audioClip, audioOut.get);
        _media.chunkFromBufferProvider = (buff) { return new SdlMixerChunk(buff); };
        _media.initialize;

        //TODO lazy load with config value
        auto cairoLibForLoad = new CairoLib;

        cairoLibForLoad.onLoad = () {
            cairoLib = cairoLibForLoad;

            import KitConfigKeys = api.dm.kit.kit_config_keys;

            if (uservices.config.hasKey(KitConfigKeys.graphicsUseVector))
            {
                const mustBeIsUseVector = uservices.config.getBool(
                    KitConfigKeys.graphicsUseVector);
                if (!mustBeIsUseVector.isNull)
                {
                    const bool isUseVector = mustBeIsUseVector.get;
                    gservices.platform.cap.isVectorGraphics = isUseVector;
                    uservices.logger.trace("Found using vector graphic from config: ", isUseVector);
                }
                else
                {
                    uservices.logger.error("Found using vector graphic key, but not value: ", KitConfigKeys
                            .graphicsUseVector);
                }
            }
            else
            {
                gservices.platform.cap.isVectorGraphics = true;
            }

            theme.isUseVectorGraphics = gservices.platform.cap.isVectorGraphics;

            uservices.logger.trace("Load Cairo library.");
        };

        cairoLibForLoad.onLoadErrors = (err) {
            uservices.logger.error("Cairo loading error: ", err);
            cairoLibForLoad.unload;
            cairoLib = null;
        };

        cairoLibForLoad.load;

        auto xmlLibForLoad = new LibxmlLib;

        xmlLibForLoad.onLoad = () {
            libxmlLib = xmlLibForLoad;
            uservices.logger.trace("Load libxml library: ", xmlLibForLoad.libVersionStr);
        };

        xmlLibForLoad.onLoadErrors = (err) {
            uservices.logger.error("Libxml loading error: ", err);
            xmlLibForLoad.unload;
            libxmlLib = null;
        };

        xmlLibForLoad.load;

        //Physics
        // auto physLibForLoad = new ChipmLib;

        // physLibForLoad.onLoad = () {
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

        if (const err = sdlLib.setEnableScreenSaver(isScreenSaverEnabled))
        {
            uservices.logger.errorf("Error screensaver: " ~ err.toString);
        }
        else
        {
            uservices.logger.trace("Screensaver: ", sdlLib.isScreenSaverEnabled);
        }

        comScreen = new SDLScreen;

        _screening = new Screening(comScreen, uservices.logging);

        import api.dm.kit.windows.windowing : Windowing;

        _windowing = new Windowing(uservices.logging);

        eventProcessor = new SdlEventProcessor(sdlKeyboard);

        eventManager = new KitEventManager;

        eventManager.windowProviderById = (windowId) {
            auto mustBeCurrentWindow = windowing.byFirstId(windowId);
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
                    _input.addKeyPress(key.keyName);
                    break;
                case release:
                    _input.addKeyRelease(key.keyName);
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
                    windowing.onWindowsById(e.ownerId, (win) {
                        win.isFocus = true;
                        e.isConsumed = true;
                        uservices.logger.tracef("Window focus on window '%s' with id %d", win.title, win
                            .id);
                        return true;
                    });
                    break;
                case focusOut:
                    windowing.onWindowsById(e.ownerId, (win) {
                        win.isFocus = false;
                        e.isConsumed = true;
                        uservices.logger.tracef("Window focus out on window '%s' with id %d", win.title, win
                            .id);
                        return true;
                    });
                    break;
                case show:
                    windowing.onWindowsById(e.ownerId, (win) {
                        win.isShowing = true;
                        e.isConsumed = true;
                        if (win.onShow.length > 0)
                        {
                            foreach (dg; win.onShow)
                            {
                                dg();
                            }
                        }
                        if (win.isStopping || win.isPausing)
                        {
                            win.run;
                        }
                        uservices.logger.tracef("Show window '%s' with id %d, state: %s", win.title, win.id, win
                            .state);
                        return true;
                    });
                    break;
                case hide:
                    windowing.onWindowsById(e.ownerId, (win) {
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
                    windowing.onWindowsById(e.ownerId, (win) {
                        win.confirmResize(e.width, e.height);
                        e.isConsumed = true;
                        return true;
                    });
                    break;
                case minimize:
                    windowing.onWindowsById(e.ownerId, (win) {
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
                    windowing.onWindowsById(e.ownerId, (win) {
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
                    windowing.onWindowsById(e.ownerId, (win) {
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
                    windowing.destroyWindowById(winId);
                    if (windowing.count == 0)
                    {
                        if (windowing.count == 0 && isQuitOnCloseAllWindows)
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

        return AppResult(isExit : false, isInit:
            true);
    }

    ComResult createSystems(CapGraphics caps)
    {
        if (!sdlLib)
        {
            sdlLib = newSdlLib;
        }

        if (!sdlFont)
        {
            sdlFont = newSdlFont;
        }

        if (caps.isAudio)
        {
            if (audioOut.isNull)
            {
                audioOut = newSdlAudio;
            }

            if (sdlAudioMixer.isNull)
            {
                sdlAudioMixer = newSdlAudioMixer;
            }
        }

        if (sdlJoystick.isNull && caps.isJoystick)
        {
            sdlJoystick = newSdlJoystick;
        }

        return ComResult.success;
    }

    ComResult initializeSystems(uint flags, CapGraphics caps)
    {
        assert(sdlLib);

        if (const err = sdlLib.setHint(SDL_HINT_APP_NAME.ptr, name))
        {
            throw new Exception(err.toString);
        }

        if (const err = sdlLib.setHint(SDL_HINT_APP_ID.ptr, id))
        {
            throw new Exception(err.toString);
        }

        if (const err = sdlLib.initialize(flags))
        {
            throw new Exception(err.toString);
        }
        uservices.logger.trace("SDL ", sdlLib.linkedVersionString);

        //TODO move to hal layer
        SDL_SetLogPriority(SDL_LOG_CATEGORY_APPLICATION, SDL_LOG_PRIORITY_WARN);

        assert(sdlFont);
        if (const err = sdlFont.initialize)
        {
            return err;
        }

        if (!audioOut.isNull)
        {
            auto audio = audioOut.get;

            ComAudioSpec defaultSpec;
            if (const err = audio.open(&defaultSpec))
            {
                return err;
            }
            uservices.logger.tracef("Open audio %s", audio.spec);

            if (!sdlAudioMixer.isNull)
            {
                auto mixer = sdlAudioMixer.get;
                if (const err = mixer.initialize)
                {
                    return err;
                }

                if (const err = mixer.open(audio.id, audio.spec))
                {
                    return err;
                }

                string chunkDecoders;
                if (const err = mixer.chunkDecoders(chunkDecoders))
                {
                    return err;
                }

                ComAudioSpec spec;
                if (const err = mixer.query(spec))
                {
                    return err;
                }

                string mixerVersion = mixer.versionString;
                uservices.logger.tracef("Init SDL mixer %s, audio: %s, decoders: %s", mixerVersion, spec, chunkDecoders);
            }
        }

        if (gservices.platform.cap.isJoystick)
        {
            assert(!sdlJoystick.isNull);
            if (const err = sdlJoystick.get.initialize)
            {
                return err;
            }

            sdlCurrentJoystick = sdlJoystick.get.currentJoystick;
        }

        return ComResult.success;
    }

    Loop newMainLoop() => new IntegratedLoop;
    SdlLib newSdlLib() => new SdlLib;
    SdlAudioDevice newSdlAudio() => new SdlAudioDevice;
    SdlMixerLib newSdlAudioMixer() => new SdlMixerLib;
    SdlTTFLib newSdlFont() => new SdlTTFLib;
    SdlJoystickLib newSdlJoystick() => new SdlJoystickLib;

    override ulong ticksMs()
    {
        assert(sdlLib);
        return sdlLib.ticksMs;
    }

    protected void initLoop(Loop loop)
    {
        loop.onExit = () => exit;
        loop.timestampMsProvider = () => ticksMs;
        loop.onDelay = () => sdlLib.delayMs(10);
        loop.onDelayTimeRestMs = (restMs) => sdlLib.delayMs(cast(uint) restMs);
        loop.onLoopUpdateMs = (timestamp) => updateLoopMs(timestamp);
        loop.onRender = (accumMsRest) => updateRender(accumMsRest);
        loop.onFreqLoopUpdateDelta = (delta) => updateFreqLoopDelta(delta);

        loop.isAutoStart = isAutoStart;
        loop.setUp;
        uservices.logger.tracef("Init loop, autostart: %s, running: %s", loop.isAutoStart, loop
                .isRunning);
    }

    override ComPlatform newComPlatform()
    {
        import api.dm.back.sdl3.sdl_platform : SDLPlatform;

        return new SDLPlatform;
    }

    override ComScreen newComScreen()
    {
        import api.dm.back.sdl3.sdl_screen : SDLScreen;

        return new SDLScreen;
    }

    SdlRenderer newRenderer(SDL_Renderer* ptr)
    {
        return new SdlRenderer(ptr);
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
        dstring title = "Window",
        int width = Window.defaultWidth,
        int height = Window.defaultHeight,
        int x = Window.defaultPosX,
        int y = Window.defaultPosY,
        Window parent = null,
        SdlWindowMode mode = SdlWindowMode.none)
    {
        import std.conv : to;

        auto sdlWindow = new SdlWindow(width, height);
        sdlWindow.mode = mode;

        auto windowBuilder = newWindowServices;
        buildPartially(windowBuilder);

        auto window = new GuiWindow(sdlWindow);
        assert(windowBuilder.windowing);
        windowBuilder.windowing.main = window;

        if (parent)
        {
            window.parent = parent;
            window.frameRate = parent.frameRate;
            window.windowing = parent.windowing;
        }
        else
        {
            window.frameRate = mainLoop.frameRate;
            window.windowing = windowing;
        }

        window.childWindowProvider = (title, width, height, x, y, parent) {
            return newWindow(title, width, height, x, y, parent);
        };

        //At the stage of initialization and window FactoryKit, not all services can be created
        buildPartially(window);

        window.initialize;
        window.create;

        assert(comScreen);
        ComScreenId screenId;
        if (const err = comScreen.getScreenForWindow(sdlWindow, screenId))
        {
            uservices.logger.error("Error getting display for window: ", window.title);
        }

        if (gpuDevice)
        {
            window.gpuDevice = gpuDevice;
            if (const err = gpuDevice.attachToWindow(sdlWindow))
            {
                uservices.logger.error(err.toString);
            }
        }

        window.screen = _platform.screen.single(screenId);
        const screenMode = window.screen.mode;
        uservices.logger.tracef("Screen id %s, %sx%s, rate %s, density %s, driver %s for window id %s, title '%s'", window.screen.id, screenMode.width, screenMode
                .height, screenMode.rateHz, screenMode.density, _screening.driverName, window.id, window
                .title);

        window.setNormalWindow;

        const int newX = (x == Window.defaultPosX) ? SDL_WINDOWPOS_UNDEFINED : x;
        const int newY = (y == Window.defaultPosY) ? SDL_WINDOWPOS_UNDEFINED : y;

        window.pos(newX, newY);

        SdlRenderer sdlRenderer = newRenderer(sdlWindow.renderer.get);
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
        uservices.logger.trace("Set theme font: ", theme.defaultMediumFont.getFontPath);

        window.theme = theme;
        window.interact = interact;

        import api.dm.kit.graphics.graphic : Graphic;

        //TODO factory method
        windowBuilder.graphic = createGraphics(uservices.logging, sdlRenderer);
        windowBuilder.graphic.initialize;

        windowBuilder.graphic.comTextureProvider = ProviderFactory!ComTexture(
            () => newComTexture(sdlRenderer),
            (dg) => newComTextureScoped(dg, sdlRenderer)
        );

        windowBuilder.graphic.comSurfaceProvider = ProviderFactory!ComSurface(
            &newComSurface,
            &newComSurfaceScoped
        );

        windowBuilder.graphic.comImageProvider = ProviderFactory!ComImage(
            &newComImage,
            &newComImageScoped
        );

        windowBuilder.isBuilt = true;

        //TODO from locale\config;
        if (mode == SdlWindowMode.none)
        {
            import api.dm.kit.assets.fonts.factories.bitmap_font_factory : BitmapFontFactory;

            //TODO build and run services after all
            import api.dm.kit.assets.fonts.bitmaps.bitmap_font : BitmapFont;

            auto comSurfProvider = ProviderFactory!ComSurface(
                &newComSurface,
                &newComSurfaceScoped
            );
            auto fontGenerator = newFontGenerator(comSurfProvider);
            windowBuilder.build(fontGenerator);

            import api.dm.kit.graphics.colors.rgba : RGBA;

            const isColorless = isFontTextureIsColorless(uservices.config, uservices.context);

            const colorText = isColorless ? RGBA.white : theme.colorText;
            const colorTextBackground = isColorless ? RGBA.black : theme.colorTextBackground;

            createFontBitmaps(fontGenerator, windowBuilder.asset, colorText, colorTextBackground, (
                    bitmap) {
                // windowBuilder.build(bitmap);
                // bitmap.initialize;
                // assert(bitmap.isInitializing);
                // bitmap.create;
                // assert(bitmap.isCreated);
            });
        }

        import api.dm.kit.factories.image_factory : ImageFactory;
        import api.dm.kit.factories.shape_factory : ShapeFactory;
        import api.dm.kit.factories.texture_factory : TextureFactory;

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
            window.graphic.dispose;
        };

        windowing.add(window);

        return window;
    }

    void clearErrors()
    {
        sdlLib.clearError;
    }

    override void exit(int code = 0)
    {
        super.exit(code);

        clearErrors;

        if (windowing)
        {
            windowing.onWindows((win) {
                if (win.isRunning)
                {
                    win.stop;
                    assert(win.isStopping);
                }
                win.dispose;
                return true;
            });
        }

        if (!sdlJoystick.isNull)
        {
            sdlJoystick.get.quit;
        }

        if (!sdlCurrentJoystick.isNull)
        {
            sdlCurrentJoystick.get.dispose;
        }

        //TODO process EXIT event
        if (!sdlAudioMixer.isNull)
        {
            sdlAudioMixer.get.quit;
        }

        if (!audioOut.isNull)
        {
            if (const err = (audioOut.get).close)
            {
                uservices.logger.error(err.toString);
            }
        }

        sdlFont.quit;

        if (gpuDevice)
        {
            gpuDevice.dispose;
            uservices.logger.trace("Dispose GPU device");
            gpuDevice = null;
        }

        if (const err = sdlLib.quit)
        {
            uservices.logger.error("Unable to quit");
        }
    }

    void updateLoopMs(size_t timestamp)
    {
        SDL_Event event;

        auto mustBeWindow = windowing.current;

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
            const startEvent = SDL_GetTicks();
            handleEvent(&event);
            const endEvent = SDL_GetTicks();

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
        const startStateTime = SDL_GetTicks();
        windowing.onWindows((window) {
            //focus may not be on the window
            if (window.isShowing)
            {
                window.draw(accumMsRest);
            }
            return true;
        });

        const endStateTime = SDL_GetTicks();

        auto mustBeWindow = windowing.current;

        if (!mustBeWindow.isNull)
        {
            mustBeWindow.get.currentScene.timeDrawProcessingMs = endStateTime - startStateTime;
        }
    }

    void updateFreqLoopDelta(double delta)
    {
        const startStateTime = SDL_GetTicks();
        windowing.onWindows((window) {
            //focus may not be on the window
            if (window.isShowing)
            {
                window.update(delta);
            }
            return true;
        });

        const endStateTime = SDL_GetTicks();

        auto mustBeWindow = windowing.current;

        if (!mustBeWindow.isNull)
        {
            mustBeWindow.get.currentScene.timeUpdateProcessingMs = endStateTime - startStateTime;
        }
    }

    void handleEvent(SDL_Event* event)
    {
        eventProcessor.process(event);

        //Ctrl + C
        if (event.type == SDL_EVENT_QUIT)
        {
            windowing.destroyAll;
            requestExit;
        }
    }
}
