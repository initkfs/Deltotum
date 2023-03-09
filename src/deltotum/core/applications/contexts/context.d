module deltotum.core.applications.contexts.context;

import deltotum.core.applications.contexts.apps.app_context: AppContext;
/**
 * Authors: initkfs
 */
class Context
{
   const AppContext appContext;

    this(const AppContext appContext){
        this.appContext = appContext;
    }
}