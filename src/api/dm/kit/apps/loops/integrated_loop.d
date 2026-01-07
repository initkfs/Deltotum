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
    in (onFreqLoopUpdateDelta)
    in (onFreqLoopUpdateDeltaFixed)
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

        //int updatesThisFrame = 0;
        //deltaTimeAccumulatorMs >= frameTimeMs && updatesThisFrame < 4

        int physicsUpdatesThisFrame = 0;

        const int MAX_PHYSICS_UPDATES = 5;

        while (deltaTimeAccumulatorMs >= physFrameMs && physicsUpdatesThisFrame < MAX_PHYSICS_UPDATES)
        {
            onFreqLoopUpdateDeltaFixed(startMs, deltaTimeMs, physDeltaSec);
            deltaTimeAccumulatorMs -= physFrameMs;
            physicsUpdatesThisFrame++;
        }

        if (physicsUpdatesThisFrame >= MAX_PHYSICS_UPDATES && deltaTimeAccumulatorMs > physFrameMs * 2)
        {
            deltaTimeAccumulatorMs = physFrameMs; //one frame
        }

        float deltaSec = deltaTimeMs / 1000.0f;
        onFreqLoopUpdateDelta(startMs, deltaTimeMs, deltaSec);

        immutable float accumRest = deltaTimeAccumulatorMs / physFrameMs;

        onRender(startMs, deltaTimeMs, accumRest);

        // if (deltaTimeAccumulatorMs < frameTimeMs)
        // {
        //     immutable delay = frameTimeMs - deltaTimeAccumulatorMs;
        //     onDelayTimeRestMs(delay);
        // }

        if (deltaTimeAccumulatorMs < 0)
        {
            deltaTimeAccumulatorMs = 0;
        }

        if(onFrameEnd){
            onFrameEnd(startMs, deltaTimeMs, physicsUpdatesThisFrame);
        }
    }
}
