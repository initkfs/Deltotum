module api.subs.ele.simulator;

import api.dm.gui.controls.containers.container : Container;

import api.subs.ele.lib.ngspice.workers.ngspice_worker: NGSpiceWorker;

import api.subs.ele.lib.ngspice;

import api.dm.lib.libxml.native;
import std.string : toStringz;
import core.sync.mutex: Mutex;
import core.sync.condition: Condition;

import std.concurrency;

/**
 * Authors: initkfs
 */
class Simulator : Container
{
    NGSpiceWorker ngWorker;

    this()
    {
        import api.dm.kit.sprites2d.layouts.managed_layout : ManagedLayout;

        layout = new ManagedLayout;
        layout.isAutoResize = true;
    }

    override void create()
    {
        super.create;

        ngWorker = new NGSpiceWorker(logger);
        ngWorker.start;

        static char*[] circuit_netlist = [
            cast(char*) "Simple DC Circuit".ptr, 
               cast(char*) "V1 in 0 DC 5".ptr,
                cast(char*)"R1 in 0 1k".ptr, 
                cast(char*) ".end".ptr,
                null // NULL terminator for the array
        ];

        import api.dm.gui.controls.switches.buttons.button: Button;

        auto btn = new Button("Run");
        addCreate(btn);

        btn.onAction ~= (ref e){
            ngWorker.tryAddCircuit(circuit_netlist.ptr);
            if(ngWorker.tryExit){
                import std;
                writeln("ADD command");
            }else {
                import std;
                writeln("FAIL command");
            }
        };
    }

    

}
