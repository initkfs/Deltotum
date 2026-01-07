module api.dm.kit.apps.loops.counters.fps_update_counter;

/**
 * Authors: initkfs
 */
class FpsUpdateCounter {
    
    float[60] logicFrameTimes = 0;
    int logicIndex = 0;
    float logicFps = 0;
    
    
    void update(float deltaTimeMs) {
        logicFrameTimes[logicIndex] = deltaTimeMs;
        logicIndex = (logicIndex + 1) % logicFrameTimes.length;
        
        float avgTime = 0;
        foreach (time; logicFrameTimes) {
            avgTime += time;
        }
        avgTime /= logicFrameTimes.length;
        
        logicFps = avgTime > 0 ? 1000.0f / avgTime : 0;
    }
    
    float fps() => logicFps;
}