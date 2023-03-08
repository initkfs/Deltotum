module deltotum.engine.physics.movement.movement_controller;

import deltotum.engine.applications.components.graphics_component : GraphicsComponent;

/**
 * Authors: initkfs
 */
abstract class MovementController : GraphicsComponent
{
    abstract void update(double delta);
}
