module api.core.apps.crashes.crash_handler;
/**
 * Authors: initkfs
 */
abstract class CrashHandler
{

    bool isConsumed;

    void acceptCrash(Throwable t, const(char)[] message = "") inout;
}
