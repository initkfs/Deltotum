module api.dm.kit.apps.loops.interrupted_loop;
import api.dm.kit.apps.loops.integrated_loop : IntegratedLoop;
import api.dm.kit.apps.loops.loop : Loop, FrameRate;

/**
 * Authors: initkfs
 */
class InterruptedLoop : IntegratedLoop
{
    this(double frameRate = FrameRate.high)
    {
        super(frameRate);
    }
    
    void update()
    in (onDelay)
    in (timestampMsProvider)
    {
        onDelay();
        immutable timeMs = timestampMsProvider();
        updateMs(timeMs);
    }

    override void run()
    {
        if (!isRunning)
        {
            quit;
            return;
        }

        if (onRun)
        {
            onRun();
        }

        update;
    }

}
