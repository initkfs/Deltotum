module deltotum.core.controllers.main_controller;

import deltotum.core.apps.uni.uni_component : UniComponent;
import deltotum.core.controllers.controller : Controller;

/**
 * Authors: initkfs
 */
abstract class MainController(C : UniComponent) : Controller!C
{
    abstract int startApp();
}
