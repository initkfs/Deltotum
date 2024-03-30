module dm.kit.apps.loops.loop;

/**
 * Authors: initkfs
 */
abstract class Loop
{
    bool isRunning;
    bool isAutoStart;

    double msInSec = 1000;
    double frameRate = 60;

    double frameTimeMs = 0;
    double updateDelta = 0;

    size_t delegate() timestampMsProvider;

    void delegate(size_t) onLoopUpdateMs;
    void delegate(double) onFreqLoopUpdateDelta;

    void delegate() onDelay;
    void delegate(double) onDelayTimeRestMs;
    void delegate(double) onRender;

    void delegate() onInit;
    void delegate() onRun;
    void delegate() onQuit;

    abstract
    {
        void updateMs(size_t);
    }

    void setUp(double deltaFactor = 100)
    {
        //TODO auto perfFreqMs = SDL_GetPerformanceFrequency() / 1000.0 / 1000;
        frameTimeMs = msInSec / frameRate;
        updateDelta = frameTimeMs / deltaFactor;
        if(isAutoStart){
            isRunning = true;
        }

        if(onInit){
            onInit();
        }
    }

    void loop()
    in (onDelay)
    in (timestampMsProvider)
    {
        while (isRunning)
        {
            onDelay();
            immutable timeMs = timestampMsProvider();
            updateMs(timeMs);
        }
    }
    
    void run()
    {
        if (onRun)
        {
            onRun();
        }

        loop;

        quit;
    }

    void quit()
    {
        isRunning = false;
        if (onQuit)
        {
            onQuit();
        }
    }
}
