module api.core.clis.printers.null_cli_printer;

import api.core.clis.printers.cli_printer : CliPrinter;

import std.getopt;

/**
 * Authors: initkfs
 */
class NullCliPrinter : CliPrinter
{
    this() @safe
    {
        super(false);
    }

    this() const @safe
    {
        super(false);
    }

    this() immutable @safe
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
