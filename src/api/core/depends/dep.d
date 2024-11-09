module api.core.depends.dep;

import api.core.components.component_service : ComponentService;
import api.core.depends.locators.service_locator : ServiceLocator;

/**
 * Authors: initkfs
 */
class Dep : ComponentService
{

    ServiceLocator locator;

    this(ServiceLocator newLocator) @safe
    {
        assert(newLocator);
        this.locator = newLocator;
    }

    this(const ServiceLocator newLocator) const @safe
    {
        assert(newLocator);
        this.locator = newLocator;
    }

    this(immutable ServiceLocator newLocator) immutable @safe
    {
        assert(newLocator);
        this.locator = newLocator;
    }

}
