module deltotum.core.controllers.controller;

import deltotum.core.apps.components.uni.uni_component : UniComponent;
import deltotum.core.apps.components.uni.uni_composite : UniComposite;

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

    void requestCleanupResources()
    {
        import core.memory : GC;

        GC.collect;
        GC.minimize;
    }
}
