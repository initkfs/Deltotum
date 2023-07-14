module deltotum.kit.apps.loops.integrated_loop;

import deltotum.kit.apps.loops.loop : Loop;

/**
 * Authors: initkfs
 */
class IntegratedLoop : Loop
{
    double deltaTimeAccumulatorLimitMs = 100;

    protected
    {
        enum msInSec = 1000;

        double deltaTimeAccumulatorMs = 0;
        double lastUpdateTimeMs = 0;

        double frameTimeMs = 0;
        double updateDelta = 0;
    }

    override void setUp()
    {
        frameTimeMs = msInSec / frameRate;
        updateDelta = frameTimeMs / 100;
    }

    override void updateMs(size_t startMs)
    in (onLoopUpdateMs)
    in (onFreqLoopUpdateDelta)
    in (onRender)
    {
        //TODO SDL_GetPerformanceCounter
        //(double)((now - start)*1000) / SDL_GetPerformanceFrequency()
        double deltaTimeMs = startMs - lastUpdateTimeMs;
        lastUpdateTimeMs = startMs;
        deltaTimeAccumulatorMs += deltaTimeMs;

        if (deltaTimeAccumulatorMs > deltaTimeAccumulatorLimitMs)
        {
            deltaTimeAccumulatorMs = deltaTimeAccumulatorLimitMs;
        }

        onLoopUpdateMs(startMs);

        while (deltaTimeAccumulatorMs > frameTimeMs)
        {
            onFreqLoopUpdateDelta(updateDelta);

            deltaTimeAccumulatorMs -= frameTimeMs;
        }

        immutable double accumRest = deltaTimeAccumulatorMs / frameTimeMs;

        onRender(accumRest);
    }
}
