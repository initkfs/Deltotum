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
    float updateFixedDeltaSec = 0;
    size_t maxFixedUpdate = 5;
    bool isControlFixedUpdate;

    //33-66ms high input, 500-1000 physics, 100-250 common, 4 * 16.666ms
    float maxAccumulatedMs = 250;

    bool isDelayLoop;

    size_t delegate() timestampMsProvider;

    void delegate(float startMs, float deltaMs, float renderRestRatio, size_t fixedFrameCount) onLoopUpdate;
    void delegate(float startMs, float deltaMs, float deltaFixedSec) onLoopUpdateFixed;

    void delegate() onStartFrame;
    void delegate(float) onDelayTimeRestMs;

    void delegate() onInit;
    void delegate() onRun;
    void delegate() onExit;

    this(float frameRate)
    {
        this.frameRate = frameRate;
        assert(frameRate > 0);

        frameTimeMs = msInSec / frameRate;
        updateFixedDeltaSec = 1.0 / frameRate;
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
    in (timestampMsProvider)
    {
        while (isRunning)
        {
            if (onStartFrame)
            {
                onStartFrame();
            }

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
