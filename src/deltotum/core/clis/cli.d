module deltotum.core.clis.cli;

import deltotum.core.clis.printers.cli_printer : CliPrinter;

import std.getopt;

/**
 * Authors: initkfs
 */
class Cli
{
    string[] cliArgs;

    CliPrinter printer;

    bool isSilentMode;

    this(string[] args, CliPrinter cliPrinter = null, bool isSilentMode = false) pure @safe
    {
        cliArgs = args;
        printer = cliPrinter ? cliPrinter : new CliPrinter;
        this.isSilentMode = isSilentMode;
    }

    this(immutable string[] args, immutable CliPrinter cliPrinter = null, bool isSilentMode = false) immutable pure @safe
    {
        cliArgs = args;
        printer = cliPrinter ? cliPrinter : new immutable CliPrinter;
        this.isSilentMode = isSilentMode;
    }

    GetoptResult parseSafe(T...)(T opt) const @safe
    {
        auto result = getopt(_cliArgs, opt);
        return result;
    }

    GetoptResult parse(T...)(T opt) const @safe
    {
        string[] argsCopy = cliArgs.dup;
        auto result = getopt(argsCopy, opt);
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

    void printOptions(string message, GetoptResult getoptResult) const
    {
        defaultGetoptPrinter(message, getoptResult.options);
    }

    void printHelp(GetoptResult getoptResult) const
    {
        printOptions("Usage:", getoptResult);
    }
}

unittest
{
    import deltotum.core.clis.printers.cli_printer : CliPrinter;

    immutable string[] args = ["bin", "-d", "data", "-b"];
   
    auto mutCli = new Cli(args.dup, new CliPrinter);
    mutCli.cliArgs = null;
    assert(mutCli.cliArgs.length == 0);

    immutable immCli = new immutable Cli(args, new immutable CliPrinter);
    assert(immCli.cliArgs.length == args.length);
    assert(typeid(immCli.cliArgs) == typeid(args));
    
    bool bArg; string strArg;
    immCli.parse("d", &strArg, "b", &bArg);
    assert(bArg);
    assert(strArg == "data");
}
