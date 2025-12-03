module api.sims.ele.lib.ngspice.workers.ngspice_worker;

import core.thread.osthread : Thread;
import api.core.utils.adt.rings.ring_buffer : RingBuffer;
import core.sync.mutex : Mutex;
import core.sync.condition : Condition;
import std.logger : Logger;

import api.sims.ele.lib.ngspice;

import std.container.dlist : DList;
import std.string : fromStringz, toStringz;

/**
 * Authors: initkfs
 */

class NGSpiceWorker : Thread
{
    protected
    {
        NGSpiceLib ngspiceLib;
        shared Mutex _mutexState;

        Logger logger;

        bool _load;
        bool _run;

        DList!(char[]) commands;
        shared Condition _commandCondition;

        char** nextCircuit;

        bool _simEnd;
    }

    RingBuffer!(char, 4096, true, false) outBuffer;
    shared Mutex outBufferMutex;

    this(Logger logger, bool isAutorun = true)
    {
        super(&run);
        this.logger = logger;

        isDaemon = true;

        commands = DList!(char[])();

        _mutexState = new shared Mutex;
        _commandCondition = new shared Condition(_mutexState);
        _run = isAutorun;

        outBufferMutex = new shared Mutex;
        outBuffer = typeof(outBuffer)(outBufferMutex);
        outBuffer.initialize;
    }

    void run()
    {
        try
        {
            auto ngspiceLibForLoad = new NGSpiceLib;

            ngspiceLibForLoad.onLoad = () {
                ngspiceLib = ngspiceLibForLoad;
                logger.trace("Load ngspace library: ", ngspiceLibForLoad.libVersionStr);
                _load = true;
            };

            ngspiceLibForLoad.onLoadErrors = (err) {
                logger.error("NGSpice loading error: ", err);
                ngspiceLibForLoad.unload;
                ngspiceLib = null;
            };

            ngspiceLibForLoad.load;

            if (!_load)
            {
                return;
            }

            assert(ngSpice_Init);
            int res = ngSpice_Init(&sendChar, null, null, &sendData, null, null, cast(void*) this);
            ngSpice_nospinit();

            logger.trace("Init ngspice: ", res);

            while (true)
            {
                if (!_run)
                {
                    break;
                }

                synchronized (_mutexState)
                {
                    if (nextCircuit)
                    {
                        //TODO send res
                        int circRes = ngSpice_Circ(nextCircuit);
                        nextCircuit = null;
                    }

                    if (!commands.empty)
                    {
                        char[] cmd = commands.front;
                        if (cmd.length > 0)
                        {
                            int cmdRet = command(cmd.ptr);
                            if (cmdRet != 0)
                            {
                                logger.error("Command error: ", cmd);
                            }
                            else
                            {
                                logger.trace("Success ngspice: ", cmd);
                            }

                            commands.removeFront;
                        }
                    }
                }

                import core.thread.osthread : Thread;
                import core.time : dur;

                Thread.sleep(dur!"msecs"(1000));
            }
        }
        catch (Exception e)
        {
            logger.error(e.toString);
        }
        catch (Throwable e)
        {
            import std.stdio : stderr;

            stderr.writeln(e);
        }
    }

    bool isSimEnd()
    {
        synchronized (_mutexState)
        {
            return _simEnd;
        }
    }

    bool tryIsSimEnd()
    {
        if (_mutexState.tryLock_nothrow)
        {
            scope (exit)
            {
                _mutexState.unlock_nothrow;
            }

            return _simEnd;
        }

        return false;
    }

    void isSimEnd(bool value)
    {
        synchronized (_mutexState)
        {
            _simEnd = value;
        }
    }

    bool tryLoad()
    {
        if (_mutexState.tryLock_nothrow)
        {
            scope (exit)
            {
                _mutexState.unlock_nothrow;
            }

            return _load;
        }

        return false;
    }

    bool isLoad()
    {
        synchronized (_mutexState)
        {
            return _load;
        }
    }

    protected void addCommandCopy(string cmd)
    {
        commands.insertBack(cmd.dup ~ ['\0']);
        //_commandCondition.notifyAll;
    }

    bool addCommand(string cmd)
    {
        synchronized (_mutexState)
        {
            addCommandCopy(cmd);
        }

        return true;
    }

    bool tryExit() => tryAddCommand("quit");

    bool tryAddCommand(string cmd)
    {
        if (_mutexState.tryLock_nothrow)
        {
            scope (exit)
            {
                _mutexState.unlock_nothrow;
            }

            addCommandCopy(cmd);

            return true;
        }

        return false;
    }

    int tryAddCircuit(char** circs)
    {
        //assert(!ngSpice_Circ); false in other thread (TLS)

        if (_mutexState.tryLock_nothrow)
        {
            scope (exit)
            {
                _mutexState.unlock_nothrow;
            }

            if (nextCircuit)
            {
                return false;
            }

            nextCircuit = circs;
            //_commandCondition.notifyAll;
            return true;
        }

        return false;
    }

    int addCircuit(char** circs)
    {
        synchronized (_mutexState)
        {
            nextCircuit = circs;
            //_commandCondition.notifyAll;
            return true;
        }
    }

    protected int command(char* cmd) => ngSpice_Command(cmd);

    extern (C) static int sendData(pvecvaluesall, int num, int id, void* data) nothrow
    {
        import std;

        debug writeln("PLOT data: ", num);
        return 0;
    }

    extern (C) static int sendChar(char* ch, int id, void* data) nothrow
    {
        NGSpiceWorker sim = cast(NGSpiceWorker) data;
        assert(sim);
        import std.string : fromStringz;

        import api.core.utils.adt.container_result : ContainerResult;

        try
        {
            import std.algorithm.searching : startsWith;

            char[] strSlice = ch.fromStringz;
            if (strSlice.startsWith("stderr"))
            {
                //idup?
                sim.logger.error(strSlice);
            }
            else
            {
                import std.algorithm.searching : canFind;

                char[] str = strSlice;
                const stdOutTag = "stdout";

                if (str.startsWith(stdOutTag))
                {
                    str = str[stdOutTag.length .. $];
                }

                auto res = sim.outBuffer.writeSync(str);
                if (!res.isSuccess)
                {
                    sim.logger.error(res);
                }

                char[1] seps = ['\n'];
                res = sim.outBuffer.writeSync(seps);
                if (!res.isSuccess)
                {
                    sim.logger.error(res);
                }

                if (strSlice.canFind("endcalc"))
                {
                    sim.isSimEnd = true;
                }
            }

        }
        catch (Exception e)
        {
            //TODO print nothrow
        }

        return 0;
    }

}
