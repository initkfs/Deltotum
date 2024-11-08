module api.core.clis.cli;

import api.core.clis.printers.cli_printer : CliPrinter;
import api.core.clis.parsers.cli_parser: CliParser;

import std.getopt;

/**
 * Authors: initkfs
 */
class Cli
{
    CliPrinter printer;
    CliParser parser;

    this(CliParser cliParser, CliPrinter cliPrinter) pure @safe
    {
        assert(cliParser);
        parser = cliParser;

        assert(cliPrinter);
        printer = cliPrinter;
    }

    this(immutable CliParser cliParser, immutable CliPrinter cliPrinter) immutable pure @safe
    {
        assert(cliParser);
        parser = cliParser;

        assert(cliPrinter);
        printer = cliPrinter;
    }

    immutable(Cli) idup() immutable
    {
        immutable iparser = parser.idup;
        immutable iprinter = printer.idup;
        //TODO cli printer
        return new immutable Cli(iparser, iprinter);
    }
}
