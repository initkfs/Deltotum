module api.dm.gui.controls.video.base_media_worker;

import core.thread.osthread : Thread;
import std.logger : Logger;

import cffmpeg;

/**
 * Authors: initkfs
 */
abstract class BaseMediaWorker : Thread
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

    string errorText(int code) const
    {
        char[256] buff = 0;
        av_strerror(code, buff.ptr, buff.length);

        import std.string : fromStringz;

        return buff.ptr.fromStringz.idup;
    }

    int codeEOF()
    {
        //TODO AVERROR_EOF
        return FFERRTAG('E', 'O', 'F', ' ');
    }

    protected AVPacket* allocCopy(AVPacket* src)
    {
        assert(src);

        AVPacket* copy = av_packet_alloc();
        av_packet_ref(copy, src);

        return copy;
    }

    void setEnd()
    {
        _end = true;
    }

}
