module api.dm.back.sdl3.sdl_app;

import api.dm.com.graphics.com_screen;

import api.dm.com.com_result : ComResult;
import api.core.loggers.logging : Logging;
import api.core.configs.keyvalues.config : Config;
import api.core.contexts.context : Context;
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

import api.dm.back.sdl3.joysticks.sdl_joystick_lib : SdlJoystickLib;
import api.dm.back.sdl3.joysticks.sdl_joystick : SdlJoystick;
import api.dm.kit.windows.events.window_event : WindowEvent;
import api.dm.kit.inputs.pointers.events.pointer_event : PointerEvent;
import api.dm.back.sdl3.sdl_texture : SdlTexture;
import api.dm.back.sdl3.sdl_surface : SdlSurface;
import api.dm.back.sdl3.fonts.sdl_ttf_font : SdlTTFFont;
import api.dm.back.sdl3.images.sdl_image : SdlImage;
import api.dm.back.sdl3.mixers.sdl_mixer_chunk : SdlMixerChunk;
import api.dm.com.graphics.com_texture : ComTexture;
import api.dm.com.graphics.com_surface : ComSurface;
import api.dm.com.graphics.com_screen : ComScreenId;
import api.dm.com.graphics.com_font : ComFont;
import api.dm.com.graphics.com_image : ComImage;
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
import KitConfigKeys = api.dm.kit.kit_config_keys;

import api.dm.lib.cairo : CairoLib;
import api.dm.lib.ffmpeg.native.binddynamic : FfmpegLib;
import api.dm.lib.portaudio.native.binddynamic : PortAudioLib;

//import api.dm.lib.chipmunk.libs : ChipmLib;

import api.dm.back.sdl3.externs.csdl3;
import std.typecons : Nullable;
import api.dm.back.sdl3.gpu.sdl_gpu_device;
import api.dm.kit.graphics.gpu.gpu_graphic : GPUGraphic;

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
        FfmpegLib ffmpegLib;
        PortAudioLib portaudioLib;

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

    this(string name, string id = null)
    {
        this.name = name;
        this.id = id.length > 0 ? id : name;
    }

    override bool initialize(string[] args)
    {
        try
        {
            if (!super.initialize(args))
            {
                return false;
            }

            if (isHeadless)
            {
                import std.process : environment;

                environment["SDL_VIDEODRIVER"] = "dummy";
                uservices.logger.infof("Headless mode enabled");
            }

            uint flags = 0;

            flags |= SDL_INIT_VIDEO;

            if (isAudioEnabled)
            {
                flags |= SDL_INIT_AUDIO;
                gservices.platform.cap.isAudio = true;
                version (EnableTrace)
                {
                    uservices.logger.trace("Audio enabled");
                }
            }

            if (isJoystickEnabled)
            {
                flags |= SDL_INIT_JOYSTICK;
                gservices.platform.cap.isJoystick = true;

                version (EnableTrace)
                {
                    uservices.logger.trace("Joystick enabled");
                }
            }

            if (onCreatedInitFlags)
            {
                flags = onCreatedInitFlags(flags);
            }

            if (const err = createSystems(gservices.platform.cap))
            {
                uservices.logger.errorf("SDL systems creation error: " ~ err.toString);
                return false;
            }

            if (onCreatedSystems)
            {
                onCreatedSystems();
            }

            if (const err = initializeSystems(flags, gservices.platform.cap))
            {
                uservices.logger.errorf("SDL systems initialization error: " ~ err.toString);
                return false;
            }

            //TODO move to systems
            import KitConfigKeys = api.dm.kit.kit_config_keys;

            gpuDevice = new SdlGPUDevice;
            if (uservices.config.hasKey(KitConfigKeys.backendIsGPU) && uservices.config.getBool(
                    KitConfigKeys.backendIsGPU))
            {
                if (const err = gpuDevice.create)
                {
                    throw new Exception(err.toString);
                }
                string gpuName;
                if (const err = gpuDevice.getDriverNameNew(gpuName))
                {
                    uservices.logger.error("Error reading GPU driver name: ", err.toString);
                }
                else
                {
                    version (EnableTrace)
                    {
                        uservices.logger.trace("Create GPU device: ", gpuName);
                    }
                }
            }

            version (EnableTrace)
            {
                uservices.logger.trace("SDL systems initialized");
            }

            if (onInitializedSystems)
            {
                onInitializedSystems();
            }

            if (!setMetadata(appname, appver, appid))
            {
                assert(sdlLib);
                uservices.logger.error("Error setting app metadata: ", sdlLib.getError);
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

            SdlJoystick currentJoy = sdlCurrentJoystick.isNull ? null : sdlCurrentJoystick.get;
            _input = new Input(uservices.logging, keyboard, clipboard, cursor, currentJoy);

            auto audioClip = new AudioMixer(sdlAudioMixer.get);

            _media = new MultiMedia(audioClip, audioOut.get);
            _media.chunkFromBufferProvider = (buff) {
                return new SdlMixerChunk(buff);
            };
            _media.initialize;

            gservices.platform.cap.isVectorGraphics = true;
            if (uservices.config.hasKey(KitConfigKeys.graphicsUseVector))
            {
                gservices.platform.cap.isVectorGraphics = uservices.config.getBool(
                    KitConfigKeys.graphicsUseVector);
            }

            if (gservices.platform.cap.isVectorGraphics)
            {
                auto cairoLibForLoad = new CairoLib;

                cairoLibForLoad.onLoad = () {
                    cairoLib = cairoLibForLoad;
                    theme.isUseVectorGraphics = gservices.platform.cap.isVectorGraphics;
                    version (EnableTrace)
                    {
                        uservices.logger.trace("Load Cairo library.");
                    }
                };

                cairoLibForLoad.onLoadErrors = (err) {
                    uservices.logger.error("Cairo loading error: ", err);
                    cairoLibForLoad.unload;
                    cairoLib = null;
                };

                cairoLibForLoad.load;
            }

            //TODO config flag
            auto ffmpegLibForLoad = new FfmpegLib;

            //TODO from config
            import std.path : buildPath;

            ffmpegLibForLoad.workDirPath = buildPath(uservices.context.app.workDir, "libs/ffmpeg/lib");

            ffmpegLibForLoad.onLoad = () {
                ffmpegLib = ffmpegLibForLoad;
                uservices.logger.trace("Load FFMPEG library.");
            };

            ffmpegLibForLoad.onLoadErrors = (err) {
                uservices.logger.error("FFMPEG loading error: ", err);
                ffmpegLibForLoad.unload;
                ffmpegLib = null;
            };

            ffmpegLibForLoad.load;

            auto audioLib = new PortAudioLib;
            audioLib.workDirPath = buildPath(uservices.context.app.workDir, "libs/portaudio/lib");

            audioLib.onLoad = () {
                audioLib.initialize;
                portaudioLib = audioLib;
                uservices.logger.tracef("Load PortAudio library: %s, dev: %s", portaudioLib.libVersionStr, portaudioLib
                        .deviceInfoNew);
            };

            audioLib.onLoadErrors = (err) {
                uservices.logger.error("PortAudio loading error: ", err);
                audioLib.unload;
                portaudioLib = null;
            };

            audioLib.load;

            if (const err = sdlLib.setEnableScreenSaver(isScreenSaverEnabled))
            {
                uservices.logger.errorf("Error screensaver: " ~ err.toString);
            }

            comScreen = new SDLScreen;

            _screening = new Screening(comScreen, uservices.logging);

            import api.dm.kit.windows.windowing : Windowing;

            _windowing = new Windowing(uservices.logging);

            eventProcessor = new SdlEventProcessor(sdlKeyboard);

            eventManager = new KitEventManager;

            eventManager.windowProviderById = (windowId) {
                auto mustBeCurrentWindow = windowing.byFirstIdOrNull(windowId);
                if (mustBeCurrentWindow && (mustBeCurrentWindow.isShowing && mustBeCurrentWindow
                        .isFocus))
                {
                    return mustBeCurrentWindow;
                }
                return null;
            };

            eventManager.currentWindowProvider = () {
                return windowing.currentOrNull;
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
                            version (EnableTrace)
                            {
                                uservices.logger.tracef("Window focus on window '%s' with id %d", win.title, win
                                    .id);
                            }
                            return true;
                        });
                        break;
                    case focusOut:
                        windowing.onWindowsById(e.ownerId, (win) {
                            win.isFocus = false;
                            e.isConsumed = true;
                            version (EnableTrace)
                            {
                                uservices.logger.tracef("Window focus out on window '%s' with id %d", win.title, win
                                    .id);
                            }
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
                            version (EnableTrace)
                            {
                                uservices.logger.tracef("Show window '%s' with id %d, state: %s", win.title, win.id, win
                                    .state);
                            }
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
                            version (EnableTrace)
                            {
                                uservices.logger.tracef("Hide window '%s' with id %d, state: %s", win.title, win.id, win
                                    .state);
                            }
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
                            version (EnableTrace)
                            {
                                uservices.logger.tracef("Minimize window '%s' with id %d", win.title, win
                                    .id);
                            }
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
                            version (EnableTrace)
                            {
                                uservices.logger.tracef("Maximize window '%s' with id %d", win.title, win
                                    .id);
                            }
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
                                version (EnableTrace)
                                {
                                    uservices.logger.tracef("All windows are closed, exit request");
                                }
                                exit;
                            }
                        }
                        break;
                    default:
                        break;
                }
            };
        }
        catch (Throwable e)
        {
            consumeThrowable(e);
            exit;
        }

        return true;
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
            sdlJoystick = newSdlJoystickLib;
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

        import KitConfigKeys = api.dm.kit.kit_config_keys;

        version (linux)
        {
            //This hint should be set before SDL is initialized.
            if (uservices.config.hasKey(KitConfigKeys.backendJoystickIsClassic))
            {
                bool isClassicDev = uservices.config.getBool(
                    KitConfigKeys.backendJoystickIsClassic);

                if (isClassicDev)
                {
                    //"0": Use /dev/input/event* (default)
                    //"1": Use /dev/input/js*
                    if (const err = sdlLib.setHint(SDL_HINT_JOYSTICK_LINUX_CLASSIC.ptr, "1".ptr))
                    {
                        uservices.logger.error("Error change joystick interface: ", err);
                    }
                    else
                    {
                        uservices.logger.infof("Set joystick classic interface");
                    }
                }
            }
        }

        if (const err = sdlLib.initialize(flags))
        {
            throw new Exception(err.toString);
        }
        uservices.logger.infof("SDL ", sdlLib.linkedVersionString);

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
                uservices.logger.infof("Init SDL mixer %s, audio: %s, decoders: %s", mixerVersion, spec, chunkDecoders);
            }
        }

        if (gservices.platform.cap.isJoystick)
        {
            assert(!sdlJoystick.isNull);
            if (const err = sdlJoystick.get.initialize)
            {
                gservices.platform.cap.isJoystick = false;
                uservices.logger.error(err);
            }
            else
            {
                //input-remapper will be found on Linux, but there may be an opening error
                SdlJoystick defaultJoystick;

                if (uservices.config.hasKey(KitConfigKeys.backendJoystickIndex))
                {
                    int index = uservices.config.getInt(KitConfigKeys.backendJoystickIndex);
                    if (index < 0)
                    {
                        throw new Exception("Joystick index must be positive number");
                    }

                    defaultJoystick = sdlJoystick.get.joystickByIndex(index);
                    if (!defaultJoystick)
                    {
                        uservices.logger.errorf("Found joystick index %s, but joystick is null. Joystics count: %s", index, sdlJoystick
                                .get.joystickCount);
                    }
                }
                else
                {
                    defaultJoystick = sdlJoystick.get.firstJoystick;
                }

                if (!defaultJoystick)
                {
                    uservices.logger.info("Not found default joystick");
                    gservices.platform.cap.isJoystick = false;
                }
                else
                {
                    sdlCurrentJoystick = defaultJoystick;

                    sdlJoystick.get.setEventsEnabled(true);

                    bool isConnected = defaultJoystick.isConnected;
                    string gname = defaultJoystick.getNameNew;
                    version (EnableTrace)
                    {
                        uservices.logger.tracef("Found joystick '%s', connected: %s, path: %s", gname, isConnected, defaultJoystick
                                .getPathNew);
                    }
                }
            }

        }

        return ComResult.success;
    }

    SdlLib newSdlLib() => new SdlLib;
    SdlAudioDevice newSdlAudio() => new SdlAudioDevice;
    SdlMixerLib newSdlAudioMixer() => new SdlMixerLib;
    SdlTTFLib newSdlFont() => new SdlTTFLib;
    SdlJoystickLib newSdlJoystickLib() => new SdlJoystickLib;

    override ulong ticksMs()
    {
        assert(sdlLib);
        return sdlLib.ticksMs;
    }

    protected void initLoop(Loop loop)
    {
        loop.onExit = () => dispose;
        loop.timestampMsProvider = () => ticksMs;

        if (uservices.config.hasKey(KitConfigKeys.loopIsDelayFrame) && uservices.config.getBool(
                KitConfigKeys.loopIsDelayFrame))
        {
            int delayMs = uservices.config.getInt(KitConfigKeys.loopDelayFrameMs);
            if (delayMs > 0)
            {
                loop.onStartFrame = () => sdlLib.delayMs(delayMs);
                version (EnableTrace)
                {
                    logger.trace("Enable loop start delay: ", delayMs);
                }
            }
        }

        if (uservices.config.hasKey(KitConfigKeys.loopIsControlFixed) && uservices.config.getBool(
                KitConfigKeys.loopIsControlFixed))
        {
            const maxAccum = uservices.config.getPositiveLong(
                KitConfigKeys.loopFixedMaxAccumFrames);
            loop.maxAccumulatedMs = maxAccum * loop.frameTimeMs;
            loop.isControlFixedUpdate = true;
            version (EnableTrace)
            {
                logger.trace("Enable fixed updates control in loop");
            }
        }

        if (uservices.config.hasKey(KitConfigKeys.loopIsDelayFixedRest) && uservices.config.getBool(
                KitConfigKeys.loopIsDelayFixedRest))
        {
            float restFactor = uservices.config.getFloat(
                KitConfigKeys.loopDelayFixedRestFactor01);
            loop.onDelayTimeRestMs = (restMs) {
                if (restFactor != 1)
                {
                    restMs *= restFactor;
                }
                sdlLib.delayNsPrec(cast(ulong)(restMs * 1_000_000));
            };
            version (EnableTrace)
            {
                logger.trace("Enable loop delay on rest frame: ");
            }
        }

        loop.onLoopUpdate = (startMs, deltaTimeMs, accumRest, fixedUpdatesCount) {
            try
            {
                updateEvents;
                updateRender(accumRest);
                updateEndFrame(startMs, deltaTimeMs, fixedUpdatesCount);
            }
            catch (Throwable e)
            {
                consumeThrowable(e);
                exit;
            }
        };
        loop.onLoopUpdateFixed = (startMs, deltaTimeMs, updateFixedDeltaSec) {
            try
            {
                updateWindows(startMs, deltaTimeMs, updateFixedDeltaSec);
            }
            catch (Throwable e)
            {
                consumeThrowable(e);
                exit;
            }
        };

        loop.isAutoStart = isAutoStart;
        loop.setUp;
        uservices.logger.infof("Init loop, fps: %f, fdt: %f sec", loop.frameRate, loop
                .updateFixedDeltaSec);

        assert(gservices.platform);
        gservices.platform.loopFixedDtSec = loop.updateFixedDeltaSec;
    }

    bool setMetadata(string appname, string appversion, string appid)
    {
        import std.string : toStringz;

        //appid - com.example.myapp
        return SDL_SetAppMetadata(appname.toStringz, appversion.toStringz, appid.toStringz);
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

        if (gpuDevice.isCreated)
        {
            window.gpuDevice = gpuDevice;
            if (const err = gpuDevice.attachToWindow(sdlWindow))
            {
                uservices.logger.error(err.toString);
            }
        }

        window.screen = _platform.screen.single(screenId);
        const screenMode = window.screen.mode;
        version (EnableTrace)
        {
            uservices.logger.tracef("Screen id %s, %sx%s, rate %s, density %s, driver %s for window id %s, title '%s'", window.screen.id, screenMode.width, screenMode
                    .height, screenMode.rateHz, screenMode.density, _screening.driverName, window.id, window
                    .title);
        }

        window.setNormalWindow;

        const int newX = (x == Window.defaultPosX) ? SDL_WINDOWPOS_UNDEFINED : x;
        const int newY = (y == Window.defaultPosY) ? SDL_WINDOWPOS_UNDEFINED : y;

        window.pos(newX, newY);

        SdlRenderer sdlRenderer = newRenderer(sdlWindow.renderer.get);
        window.renderer = sdlRenderer;

        if (uservices.config.hasKey(KitConfigKeys.engineIsVsync))
        {
            const isVsync = uservices.config.getBool(KitConfigKeys.engineIsVsync);
            if (!isVsync)
            {
                if (const err = window.renderer.setVsync(SDL_RENDERER_VSYNC_DISABLED))
                {
                    uservices.logger.error("Disabling vsync error: ", err.toString);
                }
                else
                {
                    version (EnableTrace)
                    {
                        uservices.logger.trace("Disable Vsync");
                    }
                }
            }
            else
            {
                int vsyncInterval = uservices.config.getInt(KitConfigKeys.engineVsyncInterval);
                if (const err = window.renderer.setVsync(vsyncInterval))
                {
                    uservices.logger.error("Unable to set vsync interval: ", err.toString);
                }
                else
                {
                    version (EnableTrace)
                    {
                        uservices.logger.trace("Set VSync interval: ", vsyncInterval);
                    }
                }
            }
        }

        if (uservices.config.hasKey(KitConfigKeys.backendCheckRendererScale) && uservices.config.getBool(
                KitConfigKeys.backendCheckRendererScale))
        {
            int rw, rh;
            if (const err = sdlRenderer.getOutputSize(rw, rh))
            {
                uservices.logger.error("Unable to detect output renderer size: ", sdlRenderer
                        .getError);
            }
            else
            {
                int windowWidth = cast(int) window.width;
                if (windowWidth > 0 && rw != windowWidth)
                {
                    float wScale = rw / window.width;
                    float hScale = rh / window.height;

                    uservices.logger.infof("Renderer output w:%dx%d, win %fx%f, set scale %fx%f", rw, rh, window.width, window
                            .height, wScale, hScale);

                    if (const err = sdlRenderer.setScale(wScale, hScale))
                    {
                        throw new Exception("Unable to set renderer scale: ", sdlRenderer.getError);
                    }
                }
            }
        }

        if (uservices.config.hasKey(KitConfigKeys.engineIsLogFpsToFile) && uservices.config.getBool(
                KitConfigKeys.engineIsLogFpsToFile))
        {
            //TODO from config;
            import std.stdio : File;
            import std.path : buildPath;
            import std.format : format;

            string logPath = buildPath(uservices.context.app.workDir, format("window_fps_log_%d.log", window
                    .id));
            try
            {
                auto fpsLog = new File(logPath, "w");
                //TODO to window
                fpsLog.writeln("update fixed");
                window.fpsLog = fpsLog;
            }
            catch (Exception e)
            {
                uservices.logger.error(e);
            }
        }

        window.title = title;

        auto asset = createAsset(uservices.logging, uservices.config, uservices.context, () {
            return newComFont;
        });
        assert(asset);
        asset.initialize;
        version (EnableTrace)
        {
            uservices.logger.trace("Build assets for window: ", window.id);
        }

        windowBuilder.asset = asset;

        theme.defaultMediumFont = asset.font;
        version (EnableTrace)
        {
            uservices.logger.trace("Set theme font: ", theme.defaultMediumFont.getFontPath);
        }

        window.theme = theme;
        window.interact = interact;

        import api.dm.kit.graphics.graphic : Graphic;

        //TODO factory method
        windowBuilder.graphic = createGraphics(uservices.logging, sdlRenderer);
        windowBuilder.graphic.initialize;

        windowBuilder.gpu = new GPUGraphic(uservices.logging, uservices.config, uservices.context, gpuDevice, window);

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
            auto isSceneDebug = uservices.config.getBool(KitConfigKeys.sceneIsDebug);
            if (isSceneDebug)
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
        if (sdlLib)
        {
            sdlLib.clearError;
        }
    }

    override void dispose()
    {
        if (uservices)
        {
            uservices.logger.trace("Dispose SDL app");
        }

        if (portaudioLib)
        {
            try
            {
                if (portaudioLib.isInit)
                {
                    portaudioLib.close;
                    uservices.logger.trace("Close audiodevice");
                }
            }
            catch (Exception e)
            {
                uservices.logger.error(e);
            }
        }

        if (hasWindowing)
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

        // if (vipsLib)
        // {
        //     vipsLib.unload;
        // }

        if (sdlFont)
        {
            sdlFont.quit;
        }

        if (gpuDevice)
        {
            gpuDevice.dispose;
            version (EnableTrace)
            {
                uservices.logger.trace("Dispose GPU device");
            }
            gpuDevice = null;
        }

        if (sdlLib)
        {
            if (const err = sdlLib.quit)
            {
                uservices.logger.error("Unable to quit");
            }
        }

        super.dispose;
    }

    void updateEvents()
    {
        SDL_Event event;

        auto currWindow = windowing.currentOrNull;

        if (currWindow)
        {
            //FIXME stop loop after destroy
            if (!currWindow.isDisposed)
            {
                currWindow.currentScene.timeEventProcessingMs = 0;
            }

        }

        while (isProcessEvents && SDL_PollEvent(&event))
        {
            const startEvent = SDL_GetTicks();
            handleEvent(&event);
            const endEvent = SDL_GetTicks();

            if (currWindow)
            {
                if (!currWindow.isDisposed)
                {
                    currWindow.currentScene.timeEventProcessingMs = endEvent - startEvent;
                }

            }
        }
    }

    void updateWindows(float startMs, float deltaTimeMs, float fixedDtSec)
    {
        const startStateTime = SDL_GetTicks();
        windowing.onWindows((window) {
            //focus may not be on the window
            if (window.isShowing)
            {
                window.update(startMs, deltaTimeMs, fixedDtSec);
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

    void updateRender(float accumMsRest)
    {
        auto currWindow = windowing.currentOrNull;

        if (!currWindow || !currWindow.isShowing)
        {
            return;
        }

        //const startStateTime = SDL_GetTicks();
        currWindow.draw(accumMsRest);
        //const endStateTime = SDL_GetTicks();
    }

    void updateEndFrame(float startMs, float deltaMs, size_t fixedUpdateCount)
    {

        auto currWindow = windowing.currentOrNull;

        if (!currWindow)
        {
            return;
        }

        currWindow.updateEndFrame(startMs, deltaMs, fixedUpdateCount);
    }

    void handleEvent(SDL_Event* event)
    {
        eventProcessor.process(event);

        //Ctrl + C
        if (event.type == SDL_EVENT_QUIT)
        {
            windowing.destroyAll;
            exit;
        }
    }
}
