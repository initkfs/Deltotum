module api.dm.gui.controls.video.base_player_worker;

import core.thread.osthread : Thread;
import std.logger : Logger;

/**
 * Authors: initkfs
 */
abstract class BasePlayerWorker : Thread
{
    protected
    {
        Logger logger;

        bool _running = true;

        bool _end;
    }

    this(Logger logger)
    {
        super(&run);
        this.logger = logger;
    }

    abstract void run();

    bool stop()
    {
        if (!_running)
        {
            return false;
        }
        _running = false;
        return true;
    }

    void setEnd()
    {
        _end = true;
    }

}
