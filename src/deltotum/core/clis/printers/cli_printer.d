module deltotum.core.clis.printers.cli_printer;

/**
 * Authors: initkfs
 */
class CliPrinter
{
    void print(T)(T message) const
    {
        import std.stdio : writeln;
        
        writeln(message);
    }
}
