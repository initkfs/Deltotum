module deltotum.phys.movement.movement_controller;

import deltotum.kit.apps.comps.window_component : WindowComponent;

/**
 * Authors: initkfs
 */
abstract class MovementController : WindowComponent
{
    abstract void update(double delta);
}
