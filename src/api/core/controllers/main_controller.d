module api.core.controllers.main_controller;

import api.core.components.uni_component : UniComponent;
import api.core.controllers.controller : Controller;

/**
 * Authors: initkfs
 */
abstract class MainController(C : UniComponent) : Controller!C
{
    abstract int startApp();
}
