module deltotum.application.sdl.sdl_application;

import deltotum.application.graphics_application : GraphicsApplication;
import deltotum.events.event_manager : EventManager;
import deltotum.hal.sdl.events.sdl_event_processor : SdlEventProcessor;
import deltotum.asset.asset_manager : AssetManager;
import deltotum.asset.fonts.font : Font;
import deltotum.scene.scene_manager : SceneManager;
import deltotum.audio.audio : Audio;
import deltotum.graphics.graphics : Graphics;
import deltotum.scene.scene : Scene;
import deltotum.input.keyboard.event.key_event : KeyEvent;

import deltotum.hal.sdl.sdl_lib : SdlLib;
import deltotum.hal.sdl.img.sdl_img_lib : SdlImgLib;
import deltotum.hal.sdl.mix.sdl_mix_lib : SdlMixLib;
import deltotum.hal.sdl.ttf.sdl_ttf_lib : SdlTTFLib;
import deltotum.hal.sdl.sdl_window: SdlWindow;
import deltotum.hal.sdl.sdl_renderer: SdlRenderer;

import deltotum.window.window : Window;
import deltotum.input.input : Input;

import std.experimental.logger : Logger, MultiLogger, FileLogger, LogLevel, sharedLog;
import std.stdio;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlApplication : GraphicsApplication
{

    private
    {
        SdlLib sdlLib;
        SdlImgLib imgLib;
        SdlMixLib audioMixLib;
        SdlTTFLib fontLib;

        //TODO check overflow and remove increment
        double deltaTime = 0;
        double deltaTimeAccumulator = 0;
        double lastUpdateTime = 0;
        int sceneWidth;
        int sceneHeight;
    }

    @property string title;
    @property double frameRate = 0;
    @property bool isRunning;
    @property EventManager eventManager;
    @property SceneManager sceneManager;

    this(string title, int sceneWidth, int sceneHeight, SdlLib lib, SdlImgLib imgLib, SdlMixLib audioMixLib, SdlTTFLib fontLib)
    {
        this.title = title;
        this.sceneWidth = sceneWidth;
        this.sceneHeight = sceneHeight;
        this.sdlLib = lib;
        this.imgLib = imgLib;
        this.audioMixLib = audioMixLib;
        this.fontLib = fontLib;
    }

    override void initialize(double frameRate = 60)
    {
        sdlLib.initialize(SDL_INIT_VIDEO | SDL_INIT_TIMER | SDL_INIT_AUDIO);

        //TODO move to hal layer
        SDL_LogSetPriority(SDL_LOG_CATEGORY_APPLICATION, SDL_LOG_PRIORITY_WARN);

        imgLib.initialize;
        audioMixLib.initialize;
        fontLib.initialize;

        this.frameRate = frameRate;

        auto multiLogger = new MultiLogger(LogLevel.trace);
        this.logger = multiLogger;
        //set new global default logger
        sharedLog = multiLogger;

        auto sdlWindow = new SdlWindow(title, SDL_WINDOWPOS_UNDEFINED,
            SDL_WINDOWPOS_UNDEFINED,
            sceneWidth,
            sceneHeight);
        auto sdlRenderer = new SdlRenderer(sdlWindow, SDL_RENDERER_ACCELERATED);
        window = new Window(sdlRenderer, sdlWindow);
        //TODO remove
        window.frameRate = frameRate;

        input = new Input;

        audio = new Audio(audioMixLib);

        graphics = new Graphics(window.renderer);

        sceneManager = new SceneManager;

        //TODO remove sdl api
        eventManager = new EventManager(sceneManager);
        eventManager.eventProcessor = new SdlEventProcessor;
        eventManager.startEvents;
        eventManager.onKey = (key) {
            if (key.event == KeyEvent.Event.keyDown)
            {
                input.justPressed = true;
                input.lastKey = key.keyCode;
            }
            else if (key.event == KeyEvent.Event.keyUp)
            {
                input.justPressed = false;
                input.lastKey = key.keyCode;
            }
        };

        enum consoleLoggerLevel = LogLevel.trace;
        auto consoleLogger = new FileLogger(stdout, consoleLoggerLevel);
        const string consoleLoggerName = "stdout_logger";
        multiLogger.insertLogger(consoleLoggerName, consoleLogger);
        logger.tracef("Create stdout logger, name '%s', level '%s'",
            consoleLoggerName, consoleLoggerLevel);

        auto assetManager = new AssetManager(logger);
        assets = assetManager;

        //TODO from config
        Font defaultFont = assetManager.font("fonts/OpenSans-Regular.ttf", 14);
        assetManager.defaultFont = defaultFont;

        isRunning = true;
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

    void addScene(Scene scene)
    {
        build(scene);
        scene.create;
        sceneManager.currentScene = scene;
    }

    override void quit()
    {
        clearErrors;
        if (window !is null)
        {
            window.destroy;
        }

        if (sceneManager !is null)
        {
            sceneManager.destroy;
        }

        //TODO auto destroy all services
        audio.destroy;

        //TODO process EXIT event
        audioMixLib.quit;
        imgLib.quit;
        sdlLib.quit;
        fontLib.quit;
    }

    void updateState(double delta)
    {
        if (window !is null)
        {
            //window.renderer.clear;
            sceneManager.update(delta);
            //window.renderer.present;
        }
    }

    override bool update()
    {
        enum msInSec = 1000;
        const frameTime = msInSec / frameRate;

        //TODO SDL_GetPerformanceCounter
        //(double)((now - start)*1000) / SDL_GetPerformanceFrequency()
        const start = SDL_GetTicks();
        deltaTime = start - lastUpdateTime;
        lastUpdateTime += deltaTime;
        deltaTimeAccumulator += deltaTime;

        SDL_Event event;

        sceneManager.currentScene.timeEventProcessing = 0;

        while (SDL_PollEvent(&event))
        {
            const startEvent = SDL_GetTicks();
            handleEvent(&event);
            const endEvent = SDL_GetTicks();
            sceneManager.currentScene.timeEventProcessing += endEvent - startEvent;
            if (!isRunning)
            {
                return isRunning;
            }
        }

        sceneManager.currentScene.timeRate = frameRate / deltaTime;

        while (deltaTimeAccumulator > frameTime)
        {
            //constant
            immutable delta = frameTime / 1000;
            const startStateTime = SDL_GetTicks();
            updateState(delta);
            const endStateTime = SDL_GetTicks();
            sceneManager.currentScene.timeUpdate = endStateTime - startStateTime;
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
