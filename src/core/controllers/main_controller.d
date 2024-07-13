module core.controllers.main_controller;

import core.components.uni_component : UniComponent;
import core.controllers.controller : Controller;

/**
 * Authors: initkfs
 */
abstract class MainController(C : UniComponent) : Controller!C
{
    abstract int startApp();
}
