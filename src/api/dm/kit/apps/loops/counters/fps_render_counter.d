module api.dm.kit.apps.loops.counters.fps_update_counter;

/**
 * Authors: initkfs
 */
class FpsUpdateCounter
{
    float[120] updateFrameTimes = 0; // 2 sec (60 FPS)
    int frameIndex = 0;
    float totalRenderTime = 0;
    int updateFrameCount = 0;
    float lastFpsUpdate = 0;
    float currentFps = 0;

    void update(float deltaTimeMs)
    {
        updateFrameTimes[frameIndex] = deltaTimeMs;
        frameIndex = (frameIndex + 1) % updateFrameTimes.length;

        totalRenderTime += deltaTimeMs;
        updateFrameCount++;

        if (totalRenderTime >= 1000.0f)
        {
            currentFps = (updateFrameCount * 1000.0f) / totalRenderTime;
            totalRenderTime = 0;
            updateFrameCount = 0;
        }
    }

    float fps() => currentFps;

    float minfps()
    {
        float maxMs = 0;
        foreach (time; updateFrameTimes)
        {
            if (time > maxMs)
                maxMs = time;
        }
        return maxMs > 0 ? 1000.0f / maxMs : 0;
    }
}
