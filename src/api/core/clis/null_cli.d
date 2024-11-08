module api.core.clis.null_cli;

import api.core.clis.cli : Cli;
import api.core.clis.parsers.null_cli_parser : NullCliParser;
import api.core.clis.printers.null_cli_printer : NullCliPrinter;

/**
 * Authors: initkfs
 */
class NullCli : Cli
{

    this() pure @safe
    {
        super(new NullCliParser, new NullCliPrinter);
    }

    this() immutable pure @safe
    {
        auto iparser = new immutable NullCliParser;
        auto iprinter = new immutable NullCliPrinter;
        super(iparser, iprinter);
    }
}
