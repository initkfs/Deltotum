module api.subs.ele.lib.ngspice.native.v45.binddynamic;

/**
 * Authors: initkfs
 */
import api.subs.ele.lib.ngspice.native.v45.types;

import api.core.utils.libs.dynamics.dynamic_loader : DynamicLoader;

extern (C) nothrow
{
    alias SendChar = int function(char*, int, void*);
    alias SendStat = int function(char*, int, void*);
    alias ControlledExit = int function(int, NG_BOOL, NG_BOOL, int, void*);
    alias SendData = int function(pvecvaluesall, int, int, void*);
    alias SendInitData = int function(pvecinfoall, int, void*);
    alias BGThreadRunning = int function(NG_BOOL, int, void*);

    int function(SendChar printfcn, SendStat statfcn, ControlledExit ngexit,
        SendData sdata, SendInitData sinitdata, BGThreadRunning bgtrun, void* userData) ngSpice_Init;

    int function(char* command) ngSpice_Command;

    int function(char** circarray) ngSpice_Circ;
    char* function() ngSpice_CurPlot;
    char** function() ngSpice_AllPlots;
    char** function(char* plotname) ngSpice_AllVecs;
    NG_BOOL function() ngSpice_running;
    NG_BOOL function(double time) ngSpice_SetBkpt;
    int function() ngSpice_nospinit;

    pvector_info function(char* vecname) ngGet_Vec_Info;
}

class NGSpiceLib : DynamicLoader
{
    override void bindAll()
    {
        bind(&ngSpice_Init, "ngSpice_Init");
        bind(&ngSpice_Command, "ngSpice_Command");
        bind(&ngSpice_Circ, "ngSpice_Circ");
        bind(&ngSpice_CurPlot, "ngSpice_CurPlot");
        bind(&ngSpice_AllPlots, "ngSpice_AllPlots");
        bind(&ngSpice_AllVecs, "ngSpice_AllVecs");
        bind(&ngSpice_running, "ngSpice_running");
        bind(&ngSpice_SetBkpt, "ngSpice_SetBkpt");
        bind(&ngSpice_nospinit, "ngSpice_nospinit");

        bind(&ngGet_Vec_Info, "ngGet_Vec_Info");
    }

    version (Windows)
    {
        const(char)[][1] paths = ["libngspice.dll"];
    }
    else version (OSX)
    {
        const(char)[][1] paths = ["libngspice.dylib"];
    }
    else version (Posix)
    {
        const(char)[][1] paths = ["libngspice.so"];
    }
    else
    {
        const(char)[0][0] paths;
    }

    override const(char[][]) libPaths()
    {
        return paths;
    }

    override int libVersion()
    {
        return 45;
    }

}
