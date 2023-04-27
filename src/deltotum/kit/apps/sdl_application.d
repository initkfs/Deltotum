module deltotum.kit.apps.sdl_application;

// dfmt off
version(SdlBackend):
// dfmt on

import deltotum.core.configs.config: Config;
import deltotum.core.contexts.context: Context;
import deltotum.core.apps.application_exit : ApplicationExit;
import deltotum.kit.apps.graphic_application : GraphicApplication;
import deltotum.kit.apps.components.graphics_component : GraphicsComponent;
import deltotum.kit.events.event_manager : EventManager;
import deltotum.sys.sdl.events.sdl_event_processor : SdlEventProcessor;
import deltotum.kit.assets.asset : Asset;
import deltotum.kit.assets.fonts.font : Font;
import deltotum.kit.scenes.scene_manager : SceneManager;
import deltotum.media.audio.audio : Audio;
import deltotum.kit.graphics.graphics : Graphics;
import deltotum.kit.interacts.interact : Interact;
import deltotum.kit.display.display_object : DisplayObject;
import deltotum.kit.scenes.scene : Scene;
import deltotum.kit.inputs.keyboard.event.key_event : KeyEvent;
import deltotum.kit.inputs.joystick.event.joystick_event : JoystickEvent;
import deltotum.kit.extensions.extension : Extension;
import deltotum.sys.sdl.sdl_lib : SdlLib;
import deltotum.sys.sdl.img.sdl_img_lib : SdlImgLib;
import deltotum.sys.sdl.mix.sdl_mix_lib : SdlMixLib;
import deltotum.sys.sdl.ttf.sdl_ttf_lib : SdlTTFLib;
import deltotum.sys.sdl.sdl_window : SdlWindow;
import deltotum.sys.sdl.sdl_renderer : SdlRenderer;
import deltotum.sys.sdl.sdl_joystick : SdlJoystick;
import deltotum.kit.windows.event.window_event : WindowEvent;
import deltotum.kit.inputs.mouse.event.mouse_event : MouseEvent;

import deltotum.kit.windows.window : Window;
import deltotum.kit.screens.screen : Screen;

import deltotum.kit.apps.loops.integrated_loop : IntegratedLoop;
import deltotum.kit.apps.loops.loop : Loop;
import deltotum.kit.windows.window_manager : WindowManager;

import std.typecons : Nullable;

import deltotum.kit.inputs.input : Input;

import std.logger : Logger, MultiLogger, FileLogger, LogLevel, sharedLog;
import std.stdio;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlApplication : GraphicApplication
{
    private
    {
        SdlLib sdlLib;
        SdlImgLib imgLib;
        SdlMixLib audioMixLib;
        SdlTTFLib fontLib;
        SdlJoystick joystick;

        Audio _audio;
        Asset _asset;
        Input _input;
        Screen _screen;
        Extension _ext;

        bool isProcessEvents = true;
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
        mainLoop.timestampProvider = () => sdlLib.getTicks;
        mainLoop.onDelay = () => sdlLib.delay(1);
        mainLoop.onLoopTimeUpdate = (timestamp) => updateLoop(timestamp);
        mainLoop.onFreqLoopDeltaUpdate = (delta) => updateFreqLoopWidthDelta(delta);

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
        _input = new Input(clipboard);
        _audio = new Audio(audioMixLib);

        _ext = createExtension(uservices.logger, uservices.config, uservices.context);

        import deltotum.sys.sdl.sdl_screen : SDLScreen;

        auto sdlScreen = new SDLScreen;
        _screen = new Screen(uservices.logger, sdlScreen);

        eventManager = new EventManager();
        eventManager.targetsProvider = (windowId) {
            auto mustBeCurrentWindow = windowManager.windowByFirstId(windowId);
            if (mustBeCurrentWindow.isNull)
            {
                return Nullable!(DisplayObject[]).init;
            }
            auto currWindow = mustBeCurrentWindow.get;
            if (!currWindow.isShowing || !currWindow.isFocus)
            {
                return Nullable!(DisplayObject[]).init;
            }
            auto targets = currWindow.scenes.currentScene.getActiveObjects;
            return Nullable!(DisplayObject[])(targets);
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
                windowManager.windowById(e.ownerId, win => win.isFocus = true);
                break;
            case focusOut:
                windowManager.windowById(e.ownerId, win => win.isFocus = false);
                break;
            case show:
                windowManager.windowById(e.ownerId, win => win.isShowing = true);
                break;
            case hide:
                windowManager.windowById(e.ownerId, win => win.isShowing = false);
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

        windowManager = new WindowManager;

        //TODO move to config
        import std.file : getcwd, exists, isDir;
        import std.path : buildPath, dirName;

        immutable assetsDirPath = "data/assets";
        immutable assetsDir = buildPath(getcwd, assetsDirPath);
        _asset = new Asset(uservices.logger, assetsDir);

        //TODO from config 
        Font defaultFont = _asset.font("fonts/NotoSans-Bold.ttf", 14);
        _asset.defaultFont = defaultFont;

        eventManager.startEvents;

        return ApplicationExit(false);
    }

    protected Extension createExtension(Logger logger, Config config, Context context)
    {
        import deltotum.kit.extensions.extension : Extension;
        import deltotum.kit.extensions.plugins.lua.lua_script_text_plugin : LuaScriptTextPlugin;
        import deltotum.kit.extensions.plugins.lua.lua_file_script_plugin : LuaFileScriptPlugin;

        //TODO from config;
        import std.path : buildPath;

        auto mustBeDataDir = context.appContext.dataDir;
        if (mustBeDataDir.isNull)
        {
            //TODO or return Nullable?
            throw new Exception("Data directory not found");
        }

        auto extension = new Extension;

        const pluginsDir = buildPath(mustBeDataDir.get, "plugins");
        import std.file : dirEntries, DirEntry, SpanMode, exists, isFile, isDir;
        import std.path : buildPath, baseName;
        import std.format : format;
        import std.conv : to;

        //TODO version(lua)

        //FIXME remove bindbc from core
        import bindbc.lua;

        const LuaSupport luaResult = loadLua();
        if (luaResult != luaSupport)
        {
            if (luaResult == luaSupport.noLibrary)
            {
                throw new Exception("Lua shared library failed to load");
            }
            else if (luaResult == luaSupport.badLibrary)
            {
                throw new Exception("One or more Lua symbols failed to load");
            }

            throw new Exception(format("Couldn't load Lua environment, received lua load result: '%s'",
                    to!string(luaSupport)));
        }

        foreach (DirEntry pluginFile; dirEntries(pluginsDir, SpanMode.shallow))
        {
            if (!pluginFile.isDir)
            {
                continue;
            }

            //TODO from config
            enum pluginMainMethod = "main";
            const filePath = buildPath(pluginsDir, "main.lua");
            if (!filePath.exists || !filePath.isFile)
            {
                continue;
            }

            const name = baseName(pluginFile);
            auto plugin = new LuaFileScriptPlugin(logger, config, context, name, filePath, pluginMainMethod);
            extension.addPlugin(plugin);
        }

        auto consolePlugin = new LuaScriptTextPlugin(logger, config, context, "console");
        extension.addPlugin(consolePlugin);

        extension.initialize;
        extension.run;

        return extension;
    }

    override Window newWindow(dstring title = "New window", int prefWidth = 600, int prefHeight = 400, int x = 0, int y = 0)
    {
        version (SdlBackend)
        {
            import deltotum.kit.windows.factories.sdl_window_factory : SdlWindowFactory;

            auto winFactory = new SdlWindowFactory;
            winFactory.audio = _audio;
            winFactory.input = _input;
            winFactory.screen = _screen;
            winFactory.ext = _ext;
            build(winFactory);

            auto window = winFactory.create(title, prefWidth, prefHeight, x, y);
            window.windowManager = windowManager;
            window.frameRate = mainLoop.frameRate;

            windowManager.add(window);
            return window;
        }
        else
        {
            assert(0);
        }
    }

    void closeWindow(long id)
    {
        uservices.logger.tracef("Request close window with id '%s'", id);
        windowManager.closeWindow(id);

        if (windowManager.windowsCount == 0 && isQuitOnCloseAllWindows)
        {
            requestQuit;
        }
    }

    void requestQuit()
    {
        mainLoop.isRunning = false;
        isProcessEvents = false;
    }

    void clearErrors()
    {
        sdlLib.clearError;
    }

    override void quit()
    {
        clearErrors;

        windowManager.iterateWindows((win) { win.destroy; return true; });

        if (_asset)
        {
            _asset.destroy;
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

        fontLib.quit;

        sdlLib.quit;
    }

    void updateLoop(size_t timestamp)
    {
        SDL_Event event;

        auto mustBeWindow = windowManager.currentWindow;

        if (!mustBeWindow.isNull)
        {
            mustBeWindow.get.scenes.currentScene.timeEventProcessingMs = 0;
        }

        while (isProcessEvents && SDL_PollEvent(&event))
        {
            const startEvent = SDL_GetTicks();
            handleEvent(&event);
            const endEvent = SDL_GetTicks();

            if (!mustBeWindow.isNull)
            {
                mustBeWindow.get.scenes.currentScene.timeEventProcessingMs = endEvent - startEvent;
            }
        }
    }

    void updateFreqLoopWidthDelta(double delta)
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
