module dm.core.controllers.main_controller;

import dm.core.units.components.uni_component : UniComponent;
import dm.core.controllers.controller : Controller;

/**
 * Authors: initkfs
 */
abstract class MainController(C : UniComponent) : Controller!C
{
    abstract int startApp();
}
