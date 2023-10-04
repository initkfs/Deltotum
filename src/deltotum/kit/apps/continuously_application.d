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

    void runLoop()
    in (mainLoop)
    {
        mainLoop.run;
    }

    void stopLoop()
    in (mainLoop)
    {
        mainLoop.isRunning = false;
    }

    override void requestQuit()
    {
        super.requestQuit;
        stopLoop;
        isProcessEvents = false;
    }

}
