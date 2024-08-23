module api.core.resources.null_resource;

import api.core.resources.resource : Resource;

import std.logger : NullLogger;

class NullResource : Resource
{
    this() @safe
    {
        super(new NullLogger);
    }
}
