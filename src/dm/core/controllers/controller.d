module dm.core.controllers.controller;

import dm.core.units.components.uni_component : UniComponent;
import dm.core.units.components.uni_composite : UniComposite;

/**
 * Authors: initkfs
 */
abstract class Controller(C : UniComponent) : UniComposite!C
{
    protected void buildController(Controller controller)
    {
        buildFromParent(controller, this);
    }

    protected void buildInitController(Controller controller)
    {
        buildController(controller);
        controller.initialize;
        if (!controller.isInitialized)
        {
            throw new Exception("Controller not initialized: " ~ controller.className);
        }
    }

    protected void buildInitRunController(Controller controller)
    {
        buildInitController(controller);
        controller.run;
        if (!controller.isRunning)
        {
            throw new Exception("Controller not running: " ~ controller.className);
        }
    }

    protected void buildInitChildController(Controller controller)
    {
        buildInitController(controller);
        addUnit(controller);
    }

    void requestGC()
    {
        //TODO update for @safe in dmd v106
        import core.memory : GC;

        GC.collect;
        GC.minimize;
    }

    void pause(size_t delayMs) const
    {
        import std.datetime : dur;
        import core.thread : Thread;

        Thread.sleep(dur!("msecs")(delayMs));
    }
}
