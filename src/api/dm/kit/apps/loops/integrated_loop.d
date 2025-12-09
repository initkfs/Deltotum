module api.dm.kit.apps.loops.integrated_loop;

import api.dm.kit.apps.loops.loop : Loop, FrameRate;

import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */
class IntegratedLoop : Loop
{
    float deltaTimeAccumLimitMs = 100;

    protected
    {
        float deltaTimeAccumulatorMs = 0;
        float lastUpdateTimeMs = 0;
    }

    this(float frameRate = FrameRate.high)
    {
        super(frameRate);
    }

    override void updateMs(size_t startMs)
    in (onLoopUpdateMs)
    in (onFreqLoopUpdateDelta)
    in (onDelayTimeRestMs)
    in (onRender)
    {
        //TODO SDL_GetPerformanceCounter
        //(float)((now - start)*1000) / SDL_GetPerformanceFrequency()
        float deltaTimeMs = startMs - lastUpdateTimeMs;
        lastUpdateTimeMs = startMs;
        deltaTimeAccumulatorMs += deltaTimeMs;

        // if (deltaTimeAccumulatorMs > deltaTimeAccumLimitMs)
        // {
        //     deltaTimeAccumulatorMs = deltaTimeAccumLimitMs;
        // }

        onLoopUpdateMs(startMs);

        //int updatesThisFrame = 0;
        //deltaTimeAccumulatorMs >= frameTimeMs && updatesThisFrame < 4
        while (deltaTimeAccumulatorMs >= frameTimeMs)
        {
            onFreqLoopUpdateDelta(updateDelta);
            deltaTimeAccumulatorMs -= frameTimeMs;
            //updatesThisFrame++;
        }

        immutable float accumRest = deltaTimeAccumulatorMs / frameTimeMs;

        onRender(accumRest);

        if (deltaTimeAccumulatorMs < frameTimeMs)
        {
            immutable delay = frameTimeMs - deltaTimeAccumulatorMs;
            onDelayTimeRestMs(delay);
        }

        if (deltaTimeAccumulatorMs < 0)
        {
            deltaTimeAccumulatorMs = 0;
        }
    }
}
