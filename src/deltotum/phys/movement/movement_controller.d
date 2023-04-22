module deltotum.phys.movement.movement_controller;

import deltotum.kit.applications.components.graphics_component : GraphicsComponent;

/**
 * Authors: initkfs
 */
abstract class MovementController : GraphicsComponent
{
    abstract void update(double delta);
}
