module core.locators.null_service_locator;

import core.locators.service_locator : ServiceLocator;

import std.logger : NullLogger;

/**
 * Authors: initkfs
 */
class NullServiceLocator : ServiceLocator
{
    this() @safe
    {
        super(new NullLogger);
    }

}
