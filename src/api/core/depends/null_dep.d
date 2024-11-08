module api.core.depends.null_dep;

import api.core.depends.dep : Dep;
import api.core.depends.locators.null_service_locator : NullServiceLocator;

/**
 * Authors: initkfs
 */
class NullDep : Dep
{
    this()
    {
        super(new NullServiceLocator);
    }

}
