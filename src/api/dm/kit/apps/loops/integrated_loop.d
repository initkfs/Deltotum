module api.dm.kit.apps.loops.integrated_loop;

import api.dm.kit.apps.loops.loop : Loop;

import api.dm.back.sdl3.externs.csdl3;

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
    in (onDelayTimeRestMs)
    in (onRender)
    {
        //TODO SDL_GetPerformanceCounter
        //(double)((now - start)*1000) / SDL_GetPerformanceFrequency()
        double deltaTimeMs = startMs - lastUpdateTimeMs;
        lastUpdateTimeMs = startMs;
        deltaTimeAccumulatorMs += deltaTimeMs;

        // if (deltaTimeAccumulatorMs > deltaTimeAccumLimitMs)
        // {
        //     deltaTimeAccumulatorMs = deltaTimeAccumLimitMs;
        // }

        onLoopUpdateMs(startMs);

        while (deltaTimeAccumulatorMs >= frameTimeMs)
        {
            onFreqLoopUpdateDelta(updateDelta);
            deltaTimeAccumulatorMs -= frameTimeMs;
        }

        immutable double accumRest = deltaTimeAccumulatorMs / frameTimeMs;

        onRender(accumRest);

        if (deltaTimeAccumulatorMs < frameTimeMs)
        {
            immutable delay = frameTimeMs - deltaTimeAccumulatorMs;
            onDelayTimeRestMs(delay);
        }
    }
}
