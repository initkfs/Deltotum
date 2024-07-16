module core.apps.app_init_ret;

import core.attribute : mustuse;

/**
 * Authors: initkfs
 */
@mustuse struct AppInitRet
{
    bool isExit;
    bool isInit;
    
    alias isInit this;
}
