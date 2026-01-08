module api.dm.kit.apps.loops.counters.fps_fixed_counter;

/**
 * Authors: initkfs
 */
class FpsFixedCounter
{
    size_t framesPerSecond = 0;
    size_t frameCounter = 0;
    float timeAccumulator = 0;

    void update(float deltaTimeMs, size_t updatesFrameCount)
    {
        frameCounter += updatesFrameCount;
        timeAccumulator += deltaTimeMs;

        if (timeAccumulator >= 1000)
        {
            framesPerSecond = frameCounter;
            frameCounter = 0;
            timeAccumulator = 0;
        }
    }

    size_t fps() => framesPerSecond;
}
