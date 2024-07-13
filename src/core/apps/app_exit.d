module core.apps.app_exit;

import core.attribute : mustuse;

/**
 * Authors: initkfs
 */
@mustuse struct AppExit
{
    bool isExit;
    bool isInit;
    
    alias isInit this;
}
