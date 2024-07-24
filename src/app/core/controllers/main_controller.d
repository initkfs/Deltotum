module app.core.controllers.main_controller;

import app.core.components.uni_component : UniComponent;
import app.core.controllers.controller : Controller;

/**
 * Authors: initkfs
 */
abstract class MainController(C : UniComponent) : Controller!C
{
    abstract int startApp();
}
