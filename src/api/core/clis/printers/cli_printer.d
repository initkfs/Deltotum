module api.core.clis.printers.cli_printer;

import std.getopt;

/**
 * Authors: initkfs
 */
class CliPrinter
{
    bool isSilentMode;

    this() pure @safe
    {

    }

    this(bool isSilentMode) pure @safe
    {
        this.isSilentMode = isSilentMode;
    }

    void print(S...)(S messages) const
    {
        import std.stdio : writeln;

        writeln(messages);
    }

    bool printIfNotSilent(lazy string message) const
    {
        if (isSilentMode)
        {
            return false;
        }

        print(message);
        return true;
    }

    void printOptions(string message, GetoptResult getoptResult) const
    {
        defaultGetoptPrinter(message, getoptResult.options);
    }

    void printHelp(GetoptResult getoptResult) const
    {
        printOptions("Usage:", getoptResult);
    }

    immutable(CliPrinter) idup() immutable
    {
        return new immutable CliPrinter;
    }
}

unittest
{
    //Immutable constructor test
    immutable cliPrinter = new immutable CliPrinter;
    assert(cliPrinter);
}
