module api.core.depends.dep;

import api.core.components.component_service : ComponentService;
import api.core.depends.locators.service_locator : ServiceLocator;

/**
 * Authors: initkfs
 */
class Dep : ComponentService
{

    ServiceLocator locator;

    this(ServiceLocator newLocator)
    {
        assert(newLocator);
        this.locator = newLocator;
    }

}
