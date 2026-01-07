module api.dm.kit.apps.loops.counters.fps_phys_counter;

/**
 * Authors: initkfs
 */
class FpsPhysCounter
{
    int physicsFramesPerSecond = 0;
    int physicsFrameCounter = 0;
    float physicsTimeAccumulator = 0;

    void update(float deltaTimeMs, int physicsUpdatesThisFrame)
    {
        physicsFrameCounter += physicsUpdatesThisFrame;
        physicsTimeAccumulator += deltaTimeMs;

        if (physicsTimeAccumulator >= 1000.0f)
        {
            physicsFramesPerSecond = physicsFrameCounter;
            physicsFrameCounter = 0;
            physicsTimeAccumulator = 0;
        }
    }

    int fps() => physicsFramesPerSecond;
}
