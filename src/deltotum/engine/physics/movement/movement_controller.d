module deltotum.engine.physics.movement.movement_controller;

import deltotum.core.application.components.uni.uni_component : UniComponent;

/**
 * Authors: initkfs
 */
abstract class MovementController : UniComponent
{
    abstract void update(double delta);
}
