module app.dm.kit.apps.loops.interrupted_loop;
import app.dm.kit.apps.loops.integrated_loop : IntegratedLoop;
import app.dm.kit.apps.loops.loop : Loop;

/**
 * Authors: initkfs
 */
class InterruptedLoop : IntegratedLoop
{
    
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
