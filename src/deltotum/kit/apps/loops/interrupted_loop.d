module deltotum.kit.apps.loops.interrupted_loop;
import deltotum.kit.apps.loops.integrated_loop : IntegratedLoop;
import deltotum.kit.apps.loops.loop : Loop;

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
