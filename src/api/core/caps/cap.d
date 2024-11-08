module api.core.caps.cap;

import api.core.components.component_service : ComponentService;
import api.core.caps.cap_core : CapCore;

/**
 * Authors: initkfs
 */
class Cap : ComponentService
{
    CapCore capCore;

    this(CapCore capCore)
    {
        this.capCore = capCore;
    }

}
