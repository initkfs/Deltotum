module api.dm.kit.apps.loops.integrated_loop;

import api.dm.kit.apps.loops.loop : Loop, FrameRate;

import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 * Loop doesn't use a classic "fixed" physical delta. Its a hybrid version with variable delta.
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
    in (onFreqLoopUpdateDelta)
    in (onFreqLoopUpdateDeltaFixed)
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

        size_t fixedUpdatesCount;

        while (deltaTimeAccumulatorMs >= frameTimeMs)
        {
            onFreqLoopUpdateDeltaFixed(startMs, deltaTimeMs, updateFixedDeltaSec);
            deltaTimeAccumulatorMs -= frameTimeMs;
            fixedUpdatesCount++;
        }

        if (fixedUpdatesCount >= maxFixedUpdate && deltaTimeAccumulatorMs > frameTimeMs * 2)
        {
            deltaTimeAccumulatorMs = frameTimeMs; //one frame
        }

        immutable float accumRest = deltaTimeAccumulatorMs / frameTimeMs;

        //float deltaSec = deltaTimeMs / 1000.0f;
        onFreqLoopUpdateDelta(startMs, deltaTimeMs, accumRest, fixedUpdatesCount);

        if (onDelayTimeRestMs && (deltaTimeAccumulatorMs < frameTimeMs))
        {
            immutable delayDtMs = frameTimeMs - deltaTimeAccumulatorMs;
            onDelayTimeRestMs(delayDtMs);
        }

        if (deltaTimeAccumulatorMs < 0)
        {
            deltaTimeAccumulatorMs = 0;
        }
    }
}
