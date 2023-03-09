module deltotum.toolkit.physics.movement.movement_controller;

import deltotum.toolkit.applications.components.graphics_component : GraphicsComponent;

/**
 * Authors: initkfs
 */
abstract class MovementController : GraphicsComponent
{
    abstract void update(double delta);
}
