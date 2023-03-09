module deltotum.core.clis.cli;

import deltotum.core.clis.printers.cli_printer: CliPrinter;

import std.getopt;

/**
 * Authors: initkfs
 */
class Cli
{
    private
    {
        string[] _cliArgs;
    }

    bool isSilentMode = false;
    CliPrinter printer;

    this(string[] args, CliPrinter cliPrinter)
    {
        import std.exception : enforce;

        enforce(cliPrinter !is null, "Cli printer must not be null");
        enforce(args !is null, "Console line arguments must not be null");
        _cliArgs = args;
        printer = cliPrinter;
    }

    GetoptResult parseSafe(T...)(T opt)
    {
        auto result = getopt(_cliArgs, std.getopt.config.passThrough, opt);
        return result;
    }

    GetoptResult parse(T...)(T opt)
    {
        auto result = getopt(_cliArgs, opt);
        return result;
    }

    bool print(string message) const
    {
        printer.print(message);
        return true;
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

    void printOptions(string message, GetoptResult getoptResult)
    {
        defaultGetoptPrinter(message, getoptResult.options);
    }

    void printHelp(GetoptResult getoptResult)
    {
        printOptions("Usage:", getoptResult);
    }

    string[] cliArgs() @safe pure nothrow const
    {
        return _cliArgs.dup;
    }
}
