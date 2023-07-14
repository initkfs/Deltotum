module deltotum.kit.apps.loops.loop;

/**
 * Authors: initkfs
 */
abstract class Loop
{
    bool isRunning;

    double frameRate = 60;

    size_t delegate() timestampMsProvider;

    void delegate(size_t) onLoopUpdateMs;
    void delegate(double) onFreqLoopUpdateDelta;

    void delegate() onDelay;
    void delegate(double) onRender;

    void delegate() onRun;
    void delegate() onQuit;

    abstract
    {
        void setUp();
        void updateMs(size_t);
    }

    void runWait()
    in (onDelay)
    in (timestampMsProvider)
    {
        setUp;

        if (onRun)
        {
            onRun();
        }

        while (isRunning)
        {
            onDelay();
            immutable timeMs = timestampMsProvider();
            updateMs(timeMs);
        }

        if (onQuit)
        {
            onQuit();
        }
    }
}
