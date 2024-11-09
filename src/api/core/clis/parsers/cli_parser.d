module api.core.clis.parsers.cli_parser;

import api.core.clis.printers.cli_printer : CliPrinter;

import std.getopt;

/**
 * Authors: initkfs
 */
class CliParser
{
    protected
    {
        string[] _cliArgs;
    }

    this(string[] args) pure @safe
    {
        _cliArgs = args;
    }

    this(const string[] args) const pure @safe
    {
        _cliArgs = args;
    }

    this(immutable string[] args) immutable pure @safe
    {
        _cliArgs = args;
    }

    GetoptResult parseSafe(T...)(T opt) const @safe
    {
        auto result = getopt(_cliArgs, opt);
        return result;
    }

    GetoptResult parse(T...)(T opt) const @safe
    {
        string[] argsCopy = _cliArgs.dup;
        auto result = getopt(argsCopy, opt);
        return result;
    }

    immutable(CliParser) idup() immutable
    {
        //TODO cli printer
        return new immutable CliParser(_cliArgs.idup);
    }

    inout(string[]) cliArgs() inout => _cliArgs;
}

unittest
{
    immutable string[] args = ["bin", "-d", "data", "-b"];

    auto mutCli = new CliParser(args.dup);
    assert(mutCli.cliArgs.length == 4);

    immutable immCli = new immutable CliParser(args);
    assert(immCli.cliArgs.length == args.length);
    assert(typeid(immCli.cliArgs) == typeid(args));
    assert(immCli.cliArgs == args);

    bool bArg;
    string strArg;
    immCli.parse("d", &strArg, "b", &bArg);
    assert(bArg);
    assert(strArg == "data");
}
