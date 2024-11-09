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

    this() const pure @safe
    {
        super(new const NullCliParser, new const NullCliPrinter);
    }

    this() immutable pure @safe
    {
        super(new immutable NullCliParser, new immutable NullCliPrinter);
    }
}
