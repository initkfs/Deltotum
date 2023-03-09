module deltotum.core.applications.crashes.crash_handler;
/**
 * Authors: initkfs
 */
abstract class CrashHandler
{

	bool isConsumed;

	abstract
	{
		abstract void acceptCrash(Throwable exFromApplication, string message = "");
	}
}
