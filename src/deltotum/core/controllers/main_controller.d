module deltotum.core.controllers.main_controller;

import deltotum.core.applications.components.uni.uni_component : UniComponent;
import deltotum.core.controllers.controller : Controller;

/**
 * Authors: initkfs
 */
abstract class MainController(C : UniComponent) : Controller!C
{

    abstract int startApplication();

    protected void pause(int timeInSec) const
    {
        import std.datetime : Duration, dur;
        import core.thread : Thread;
        import std.exception : enforce;

        enforce(timeInSec > 0, "Pause time must be a positive number");

        Thread.sleep(dur!("seconds")(timeInSec));
    }
}
