module api.dm.kit.apps.loops.counters.fps_render_counter;

/**
 * Authors: initkfs
 */
class FpsRenderCounter
{
    float[120] renderFrameTimes = 0; // 2 sec (60 FPS)
    int frameIndex = 0;
    float totalRenderTime = 0;
    int renderFrameCount = 0;
    float lastFpsUpdate = 0;
    float currentFps = 0;

    void update(float deltaTimeMs)
    {
        renderFrameTimes[frameIndex] = deltaTimeMs;
        frameIndex = (frameIndex + 1) % renderFrameTimes.length;

        totalRenderTime += deltaTimeMs;
        renderFrameCount++;

        if (totalRenderTime >= 1000.0f)
        {
            currentFps = (renderFrameCount * 1000.0f) / totalRenderTime;
            totalRenderTime = 0;
            renderFrameCount = 0;
        }
    }

    float fps() => currentFps;

    float minfps()
    {
        float maxMs = 0;
        foreach (time; renderFrameTimes)
        {
            if (time > maxMs)
                maxMs = time;
        }
        return maxMs > 0 ? 1000.0f / maxMs : 0;
    }
}
