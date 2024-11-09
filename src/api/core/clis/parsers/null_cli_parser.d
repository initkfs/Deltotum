module api.core.clis.parsers.null_cli_parser;

import api.core.clis.parsers.cli_parser: CliParser;

/**
 * Authors: initkfs
 */
class NullCliParser : CliParser
{

    this() pure @safe
    {
        super(null);
    }

    this() const pure @safe
    {
        super(null);
    }

    this() immutable pure @safe
    {
        super(null);
    }
}
