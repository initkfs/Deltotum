module api.core.depends.null_dep;

import api.core.depends.dep : Dep;
import api.core.depends.locators.null_service_locator : NullServiceLocator;

/**
 * Authors: initkfs
 */
class NullDep : Dep
{
    this() @safe
    {
        super(new NullServiceLocator);
    }

    this() const @safe
    {
        super(new const NullServiceLocator);
    }

    this() immutable @safe
    {
        super(new immutable NullServiceLocator);
    }

}
