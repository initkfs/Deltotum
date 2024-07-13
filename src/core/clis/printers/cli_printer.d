module core.clis.printers.cli_printer;

/**
 * Authors: initkfs
 */
class CliPrinter
{
    void print(S...)(S messages) const
    {
        import std.stdio : writeln;
        
        writeln(messages);
    }
}

unittest {
    //Immutable constructor test
    immutable cliPrinter = new immutable CliPrinter;
    assert(cliPrinter);
}
