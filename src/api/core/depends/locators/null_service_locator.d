module api.core.depends.locators.null_service_locator;

import api.core.depends.locators.service_locator : ServiceLocator;
import api.core.loggers.null_logging : NullLogging;

/**
 * Authors: initkfs
 */
class NullServiceLocator : ServiceLocator
{
    this() @safe
    {
        super(new NullLogging);
    }

    this() const @safe
    {
        super(new const NullLogging);
    }

    this() immutable @safe
    {
        super(new immutable NullLogging);
    }

}
