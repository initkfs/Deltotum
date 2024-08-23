module api.dm.kit.apps.continuously_application;

import api.dm.kit.apps.graphic_application : GraphicApplication;
import api.dm.kit.apps.loops.loop : Loop;

/**
 * Authors: initkfs
 */
abstract class ContinuouslyApplication : GraphicApplication
{
    bool isAutoStart = true;

    Loop mainLoop;
    bool isProcessEvents = true;

    this(Loop loop)
    {
        import std.exception : enforce;

        this.mainLoop = enforce(loop, "Main loop must not be null");
    }

    override void run()
    {
        super.run;

        assert(mainLoop);
        mainLoop.run;
    }

    override void stop()
    {
        super.stop;

        assert(mainLoop);
        mainLoop.isRunning = false;
    }

    override void requestExit()
    {
        super.requestExit;
        stop;
        isProcessEvents = false;
    }

}
