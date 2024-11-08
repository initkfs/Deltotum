module api.core.clis.parsers.null_cli_parser;

import api.core.clis.parsers.cli_parser: CliParser;

/**
 * Authors: initkfs
 */
class NullCliParser : CliParser
{

    this() pure @safe
    {
        super([]);
    }

    this() immutable pure @safe
    {
        super([]);
    }
}
