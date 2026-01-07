module api.dm.kit.apps.loops.loop;

enum FrameRate
{
    low = 30,
    medium = 50,
    high = 60,
    ultra = 120
}

/**
 * Authors: initkfs
 */
abstract class Loop
{
    bool isRunning;
    bool isAutoStart;

    float msInSec = 1000;
    float frameRate = 0;

    float frameTimeMs = 0;
    float updateDelta = 0;

    float physFps = 60.0f;
    float physFrameMs = 1000.0f / 60.0;
    float physDeltaSec = 1.0f / 60.0;

    size_t delegate() timestampMsProvider;

    void delegate(float startMs, float dt) onFreqLoopUpdateDelta;
    void delegate(float dt) onFreqLoopUpdateDeltaFixed;

    void delegate() onDelay;
    void delegate(float) onDelayTimeRestMs;
    void delegate(float) onRender;

    void delegate() onInit;
    void delegate() onRun;
    void delegate() onExit;

    this(float frameRate)
    {
        this.frameRate = frameRate;
        assert(frameRate > 0);

        //TODO auto perfFreqMs = SDL_GetPerformanceFrequency() / 1000.0 / 1000;
        frameTimeMs = msInSec / frameRate;
        //or 1.0 / frameTimeMs, ~0.016666
        //updateDelta = frameTimeMs / deltaFactor; //deltaFactor == 100
        updateDelta = 1.0 / frameRate;
    }

    abstract
    {
        void updateMs(size_t);
    }

    void setUp()
    {
        if (isAutoStart)
        {
            isRunning = true;
        }

        if (onInit)
        {
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
        if (onExit)
        {
            onExit();
        }
    }
}
