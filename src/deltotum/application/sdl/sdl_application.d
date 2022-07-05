module deltotum.application.sdl.sdl_application;

import deltotum.application.graphics_application : GraphicsApplication;
import deltotum.event.sdl.sdl_event_manager : SdlEventManager;
import deltotum.asset.asset_manager : AssetManager;
import deltotum.state.state_manager : StateManager;
import deltotum.state.state : State;

import deltotum.hal.sdl.sdl_lib : SdlLib;
import deltotum.hal.sdl.img.sdl_img_lib : SdlImgLib;
import deltotum.window.window : Window;

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

        //TODO check overflow and remove increment
        double deltaTime = 0;
        double deltaTimeAccumulator = 0;
        double lastUpdateTime = 0;
    }

    @property double frameRate = 0;
    @property bool isRunning;
    @property void delegate(double) onUpdate;
    @property SdlEventManager eventManager;
    @property StateManager stateManager;

    this(SdlLib lib, SdlImgLib imgLib)
    {
        this.sdlLib = lib;
        this.imgLib = imgLib;
    }

    override void initialize(double frameRate = 60)
    {
        sdlLib.initialize(SDL_INIT_VIDEO | SDL_INIT_TIMER | SDL_INIT_AUDIO);

        //TODO move to hal layer
        SDL_LogSetPriority(SDL_LOG_CATEGORY_APPLICATION, SDL_LOG_PRIORITY_WARN);

        imgLib.initialize;

        this.frameRate = frameRate;

        auto multiLogger = new MultiLogger(LogLevel.trace);
        this.logger = multiLogger;
        //set new global default logger
        sharedLog = multiLogger;

        eventManager = new SdlEventManager;

        stateManager = new StateManager;

        enum consoleLoggerLevel = LogLevel.trace;
        auto consoleLogger = new FileLogger(stdout, consoleLoggerLevel);
        const string consoleLoggerName = "stdout_logger";
        multiLogger.insertLogger(consoleLoggerName, consoleLogger);
        logger.tracef("Create stdout logger, name '%s', level '%s'",
            consoleLoggerName, consoleLoggerLevel);

        auto assetManager = new AssetManager(logger);
        assets = assetManager;

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

    void addState(State state)
    {
        build(state);
        state.create;
        stateManager.setState(state);
    }

    override void quit()
    {
        clearErrors;
        if (window !is null)
        {
            window.destroy;
        }

        if (stateManager !is null)
        {
            stateManager.destroy;
        }
        //TODO process EXIT event
        imgLib.quit;
        sdlLib.quit;
    }

    void updateState(double delta)
    {
        if (window !is null)
        {
            window.renderer.clear;
            stateManager.update(delta);
            window.renderer.present;
        }
    }

    override bool update()
    {
        deltaTime = SDL_GetTicks() - lastUpdateTime;
        lastUpdateTime += deltaTime;
        deltaTimeAccumulator += deltaTime;

        enum msInSec = 1000;
        const frameTime = msInSec / frameRate;

        SDL_Event event;

        while (SDL_PollEvent(&event))
        {
            handleEvent(&event);
            if (!isRunning)
            {
                return isRunning;
            }
        }

        while (deltaTimeAccumulator > frameTime)
        {
            //constant
            immutable delta = frameTime / 1000;
            if (onUpdate !is null)
            {
                onUpdate(delta);
            }
            updateState(delta);
            deltaTimeAccumulator -= frameTime;
        }

        return true;
    }

    void handleEvent(SDL_Event* event)
    {
        eventManager.process(event);

        if (event.type == SDL_QUIT)
        {
            isRunning = false;
            return;
        }
    }
}
