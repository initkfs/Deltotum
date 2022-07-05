module deltotum.application.sdl.sdl_application;

import deltotum.application.graphics_application : GraphicsApplication;
import deltotum.event.sdl.sdl_event_manager : SdlEventManager;
import deltotum.asset.asset_manager : AssetManager;

import deltotum.hal.sdl.sdl_lib : SdlLib;
import deltotum.hal.sdl.img.sdl_img_lib : SdlImgLib;

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
        SdlEventManager eventManager;

        //TODO check overflow and remove increment
        double deltaTime = 0;
        double deltaTimeAccumulator = 0;
        double lastUpdateTime = 0;
    }

    @property double frameRate = 0;
    @property bool isRunning;
    @property void delegate(double) onUpdate;

    this(SdlLib lib, SdlImgLib imgLib, SdlEventManager eventManager)
    {
        this.sdlLib = lib;
        this.imgLib = imgLib;
        this.eventManager = eventManager;
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

    override void quit() const @nogc nothrow
    {
        //TODO process EXIT event
        imgLib.quit;
        sdlLib.quit;
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
            if (onUpdate !is null)
            {
                //TODO, constant
                onUpdate(frameTime / 1000);
            }
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
