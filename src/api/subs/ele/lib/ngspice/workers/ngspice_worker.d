module api.subs.ele.lib.ngspice.workers.ngspice_worker;

import core.thread.osthread : Thread;
import core.sync.mutex : Mutex;
import core.sync.condition : Condition;
import std.logger : Logger;

import api.subs.ele.lib.ngspice;

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
    }

    this(Logger logger, bool isAutorun = true)
    {
        super(&run);
        this.logger = logger;

        isDaemon = true;

        commands = DList!(char[])();

        _mutexState = new shared Mutex;
        _commandCondition = new shared Condition(_mutexState);
        _run = isAutorun;
    }

    void run()
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

        logger.trace("Load simulator");

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
                if(nextCircuit){
                    //TODO send res
                    int circRes = ngSpice_Circ(nextCircuit);
                    nextCircuit = null;
                }

                while (commands.empty)
                {
                    _commandCondition.wait;
                }

                char[] cmd = commands.front;
                if (cmd.length > 0)
                {
                    int cmdRet = command(cmd.ptr);
                    if (cmdRet != 0)
                    {
                        logger.error("Command error: ", cmd);
                    }

                    commands.removeFront;
                }
            }
        }
    }

    protected void addCommandCopy(string cmd)
    {
        commands.insertBack(cmd.dup);
        _commandCondition.notifyAll;
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

            if(nextCircuit){
                return false;
            }
            
            nextCircuit = circs;
            _commandCondition.notifyAll;
            return true;
        }

        return false;
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

        try
        {
            sim.logger.trace(ch.fromStringz);
        }
        catch (Exception e)
        {
            //TODO print nothrow
        }
        return 0;
    }

}
