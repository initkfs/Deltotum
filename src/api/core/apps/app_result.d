module api.core.apps.app_result;

import core.attribute : mustuse;

/**
 * Authors: initkfs
 */
@mustuse struct AppResult
{
    bool isExit;
    bool isInit;
}
