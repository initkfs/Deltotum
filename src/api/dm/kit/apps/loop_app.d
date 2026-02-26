module api.dm.kit.apps.loop_app;

import api.dm.kit.apps.graphic_app : GraphicApp;
import api.dm.kit.apps.loops.loop : Loop;
import api.dm.kit.apps.loops.integrated_loop : IntegratedLoop;

/**
 * Authors: initkfs
 */
abstract class LoopApp : GraphicApp
{
    bool isAutoStart = true;

    Loop mainLoop;
    bool isProcessEvents = true;

    override bool initialize(string[] args)
    {
        if (!super.initialize(args))
        {
            return false;
        }

        mainLoop = newMainLoop;
        assert(mainLoop);

        return true;
    }

    Loop newMainLoop()
    {
        import KitConfigKeys = api.dm.kit.kit_config_keys;

        float frameRate = 0;
        if (uservices.config.hasKey(KitConfigKeys.engineFrameRate))
        {
            frameRate = uservices.config.getDouble(KitConfigKeys.engineFrameRate);
        }

        if (frameRate != 0)
        {
            return new IntegratedLoop(frameRate);
        }

        return new IntegratedLoop;
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

    override void exit()
    {
        if (isRunning)
        {
            stop;
        }
        isProcessEvents = false;
        super.exit;
    }

}
