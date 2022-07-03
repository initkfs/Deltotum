module deltotum.application.sdl.sdl_application;

import deltotum.application.graphics_application : GraphicsApplication;
import deltotum.event.sdl.sdl_event_manager : SdlEventManager;

import deltotum.hal.sdl.sdl_lib : SdlLib;
import deltotum.hal.sdl.img.sdl_img_lib : SdlImgLib;

import std.stdio;
import std.math.rounding : floor;

import bindbc.sdl;

class SdlApplication : GraphicsApplication
{

    private
    {
        SdlLib sdlLib;
        SdlImgLib imgLib;
        SdlEventManager eventManager;
        double frameRate = 0;
        uint lastUpdate;

        bool inBackground;
        double lastElapsedMs;
    }

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
        isRunning = true;
    }

    override void runWait()
    {
        while (isRunning)
        {
            update;
        }
    }

    override void quit()
    {
        //TODO process EXIT event
        imgLib.quit;
        sdlLib.quit;
    }

    override bool update()
    {
        ulong start = SDL_GetPerformanceCounter();
        SDL_Event event;

        while (SDL_PollEvent(&event))
        {
            handleEvent(&event);
            if (!isRunning)
            {
                return isRunning;
            }
        }

        if (onUpdate !is null)
        {
            onUpdate(lastElapsedMs);
        }

        double freq = cast(double) SDL_GetPerformanceFrequency();
        ulong end = SDL_GetPerformanceCounter();

        enum double msInSec = 1000.0;
        auto elapsedMs = (end - start) / freq * msInSec;
        //TODO floor, compare double
        double freqMs = msInSec / frameRate;
        uint delayMs = 0;
        if (elapsedMs < freqMs)
        {
            lastElapsedMs = elapsedMs;
            delayMs = cast(uint)(freqMs - lastElapsedMs);
            SDL_Delay(delayMs);
            import std.stdio;

            writeln(1000 / delayMs);
        }

        return true;
    }

    void handleEvent(SDL_Event* event)
    {
        if (event.type == SDL_QUIT)
        {
            isRunning = false;
            return;
        }

        eventManager.process(event);
    }

}
