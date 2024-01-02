module dm.core.apps.crashes.crash_handler;
/**
 * Authors: initkfs
 */
abstract class CrashHandler
{

	bool isConsumed;

	abstract
	{
		void acceptCrash(Throwable t, const(char)[] message = "") inout;
	}
}
