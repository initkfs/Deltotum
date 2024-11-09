module api.core.clis.printers.null_cli_printer;

import api.core.clis.printers.cli_printer: CliPrinter;

import std.getopt;

/**
 * Authors: initkfs
 */
class NullCliPrinter : CliPrinter
{
    this() pure @safe
    {
        super(false);
    }

    this() const pure @safe
    {
        super(false);
    }

    this() immutable pure @safe
    {
        super(false);
    }

    void print(S...)(S messages) const
    {
        
    }

    override bool printIfNotSilent(lazy string message) const
    {
       return false;
    }

    override void printOptions(string message, GetoptResult getoptResult) const
    {
       
    }

    override void printHelp(GetoptResult getoptResult) const
    {
        
    }
}
