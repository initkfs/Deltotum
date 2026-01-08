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
    in (onLoopUpdate)
    in (onLoopUpdateFixed)
    {
        //TODO (0xFFFFFFFF - lastUpdateTimeMs) + currentTime + 1;
        immutable float deltaTimeMs = startMs - lastUpdateTimeMs;
        lastUpdateTimeMs = startMs;
        deltaTimeAccumulatorMs += deltaTimeMs;

        if (isControlFixedUpdate && deltaTimeAccumulatorMs > maxAccumulatedMs)
        {
            deltaTimeAccumulatorMs = maxAccumulatedMs;
        }

        size_t fixedUpdatesCount;
        while (deltaTimeAccumulatorMs >= frameTimeMs)
        {
            onLoopUpdateFixed(startMs, deltaTimeMs, updateFixedDeltaSec);
            deltaTimeAccumulatorMs -= frameTimeMs;
            fixedUpdatesCount++;
        }

        // if (isControlFixedUpdate && fixedUpdatesCount >= maxFixedUpdate && deltaTimeAccumulatorMs > frameTimeMs * 2)
        // {
        //     deltaTimeAccumulatorMs = frameTimeMs; //one frame
        // }

        immutable float accumRest = deltaTimeAccumulatorMs / frameTimeMs;

        //float deltaSec = deltaTimeMs / 1000.0f;
        onLoopUpdate(startMs, deltaTimeMs, accumRest, fixedUpdatesCount);

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
