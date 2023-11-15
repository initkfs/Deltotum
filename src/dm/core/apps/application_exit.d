module dm.core.apps.application_exit;

import core.attribute : mustuse;

/**
 * Authors: initkfs
 */
@mustuse struct ApplicationExit
{
    bool isExit;
    
    alias isExit this;
}
