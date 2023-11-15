module dm.kit.apps.loops.integrated_loop;

import dm.kit.apps.loops.loop : Loop;

/**
 * Authors: initkfs
 */
class IntegratedLoop : Loop
{
    double deltaTimeAccumLimitMs = 100;

    protected
    {
        double deltaTimeAccumulatorMs = 0;
        double lastUpdateTimeMs = 0;
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

        if (deltaTimeAccumulatorMs > deltaTimeAccumLimitMs)
        {
            deltaTimeAccumulatorMs = deltaTimeAccumLimitMs;
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
