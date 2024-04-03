module dm.core.clis.null_cli;

import dm.core.clis.cli : Cli;

/**
 * Authors: initkfs
 */
class NullCli : Cli
{

    this() pure @safe
    {
        super([], null, true);
    }

    this() immutable pure @safe
    {
        super([], null, true);
    }
}
