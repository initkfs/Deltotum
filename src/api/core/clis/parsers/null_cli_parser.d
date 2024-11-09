module api.core.clis.parsers.null_cli_parser;

import api.core.clis.parsers.cli_parser : CliParser;

/**
 * Authors: initkfs
 */
class NullCliParser : CliParser
{

    this() @safe
    {
        super(null);
    }

    this() const @safe
    {
        super(null);
    }

    this() immutable @safe
    {
        super(null);
    }
}
