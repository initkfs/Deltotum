module api.subs.ele.simulator;

import api.dm.gui.controls.containers.container : Container;

import api.subs.ele.lib.ngspice;

import api.dm.lib.libxml.native;
import std.string : toStringz;

/**
 * Authors: initkfs
 */
class Simulator : Container
{

    NGSpiceLib ngspiceLib;

    this()
    {
        import api.dm.kit.sprites2d.layouts.managed_layout : ManagedLayout;

        layout = new ManagedLayout;
        layout.isAutoResize = true;
    }

    override void create()
    {
        super.create;

        auto ngspiceLibForLoad = new NGSpiceLib;

        ngspiceLibForLoad.onLoad = () {
            ngspiceLib = ngspiceLibForLoad;
            logger.trace("Load ngspace library: ", ngspiceLibForLoad.libVersionStr);
        };

        ngspiceLibForLoad.onLoadErrors = (err) {
            logger.error("NGSpice loading error: ", err);
            ngspiceLibForLoad.unload;
            ngspiceLib = null;
        };

        ngspiceLibForLoad.load;

        logger.trace("Load simulator");

        char*[] circuit_netlist = [
            cast(char*) "Simple DC Circuit".ptr, 
               cast(char*) "V1 in 0 DC 5".ptr,
                cast(char*)"R1 in 0 1k".ptr, 
                cast(char*) ".end".ptr,
                null // NULL terminator for the array
        ];

        int res = ngSpice_Init(&sendChar, null, null, null, null, null, cast(void*) this);
        res = ngSpice_Command(cast(char*)("echo run no. 1".toStringz));
        // res = ngSpice_Command(cast(char*)(
        //         "source /home/user/Account/Downloads/ngspice-45.tar/test.cir".toStringz));

        res = ngSpice_Circ(circuit_netlist.ptr);
        res = ngSpice_Command(cast(char*)("op".toStringz));
        res = ngSpice_Command(cast(char*)("print in".toStringz));

        import std;

        writeln(res);

    }

    extern (C) static int sendChar(char* ch, int id, void* data) nothrow
    {
        Simulator sim = cast(Simulator) data;
        import std.string : fromStringz;

        try
        {
            sim.logger.trace(ch.fromStringz);
        }
        catch (Exception e)
        {

        }
        return 0;
    }

}
