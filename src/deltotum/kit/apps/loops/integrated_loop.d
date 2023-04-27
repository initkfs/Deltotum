module deltotum.kit.apps.loops.integrated_loop;

import deltotum.kit.apps.loops.loop : Loop;

/**
 * Authors: initkfs
 */
class IntegratedLoop : Loop
{
    double deltaTime = 0;
    double deltaTimeAccumulator = 0;
    double lastUpdateTime = 0;

    private
    {
        enum msInSec = 1000;
    }

    override void update(size_t start)
    {
        const frameTime = msInSec / frameRate;
        //TODO SDL_GetPerformanceCounter
        //(double)((now - start)*1000) / SDL_GetPerformanceFrequency()
        deltaTime = start - lastUpdateTime;
        lastUpdateTime = start;
        deltaTimeAccumulator += deltaTime;

        onLoopTimeUpdate(start);

        while (deltaTimeAccumulator > frameTime)
        {
            immutable delta = frameTime / 100;

            onFreqLoopDeltaUpdate(delta);

            deltaTimeAccumulator -= frameTime;
        }
    }
}
