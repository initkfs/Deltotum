module dm.core.resources.null_resource;

import dm.core.resources.resource : Resource;

import std.logger : NullLogger;

class NullResource : Resource
{
    this() @safe
    {
        super(new NullLogger);
    }
}
