module deltotum.kit.apps.continuously_application;

import deltotum.kit.apps.graphic_application : GraphicApplication;
import deltotum.kit.apps.loops.loop : Loop;

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

    override void requestQuit()
    {
        super.requestQuit;
        stop;
        isProcessEvents = false;
    }

}
