module deltotum.kit.apps.loops.integrated_loop;

import deltotum.kit.apps.loops.loop : Loop;

/**
 * Authors: initkfs
 */
class IntegratedLoop : Loop
{
    double deltaTimeAccumulatorLimitMs = 100;

    private
    {
        enum msInSec = 1000;
        
        double deltaTimeAccumulatorMs = 0;
        double lastUpdateTimeMs = 0;

        double frameTimeMs = 0;
        double updateDelta = 0;
    }

    this(){
        frameTimeMs = msInSec / frameRate;
        updateDelta = frameTimeMs / 100;
    }

    override void updateMs(size_t startMs)
    {
        //TODO SDL_GetPerformanceCounter
        //(double)((now - start)*1000) / SDL_GetPerformanceFrequency()
        double deltaTimeMs = startMs - lastUpdateTimeMs;
        lastUpdateTimeMs = startMs;
        deltaTimeAccumulatorMs += deltaTimeMs;

        if(deltaTimeAccumulatorMs > deltaTimeAccumulatorLimitMs){
            deltaTimeAccumulatorMs = deltaTimeAccumulatorLimitMs;
        }

        onLoopUpdateMs(startMs);

        while (deltaTimeAccumulatorMs > frameTimeMs)
        {
            onFreqLoopUpdateDelta(updateDelta);

            deltaTimeAccumulatorMs -= frameTimeMs;
        }

        const double accumRest = deltaTimeAccumulatorMs / frameTimeMs;

        onRender(accumRest);
    }
}
