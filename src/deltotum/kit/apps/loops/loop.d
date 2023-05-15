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
    void delegate() onRender;
    void delegate() onQuit;

    abstract
    {
        void updateMs(size_t);
    }

    void runWait()
    {
        assert(timestampMsProvider);
        assert(onLoopUpdateMs);
        assert(onFreqLoopUpdateDelta);
        assert(onDelay);
        assert(onRender);
        assert(onQuit);

        while (isRunning)
        {
            onDelay();
            immutable time = timestampMsProvider();
            updateMs(time);
        }

        onQuit();
    }
}
