module deltotum.kit.apps.loops.loop;

/**
 * Authors: initkfs
 */
abstract class Loop
{
    bool isRunning;

    double frameRate = 60;

    size_t delegate() timestampProvider;

    void delegate(size_t) onLoopTimeUpdate;
    void delegate(double) onFreqLoopDeltaUpdate;
    void delegate() onDelay;
    void delegate() onQuit;

    abstract
    {
        void update(size_t);
    }

    void runWait()
    {
        assert(timestampProvider);
        assert(onLoopTimeUpdate);
        assert(onFreqLoopDeltaUpdate);
        assert(onDelay);
        assert(onQuit);

        while (isRunning)
        {
            onDelay();
            immutable time = timestampProvider();
            update(time);
        }

        onQuit();
    }
}
