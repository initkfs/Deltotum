module deltotum.engine.physics.movement.complex_movement_controller;

import deltotum.engine.physics.movement.movement_controller : MovementController;

import deltotum.engine.display.display_object : DisplayObject;
import deltotum.engine.physics.direction : Direction;

/**
 * Authors: initkfs
 */
class ComplexMovementController : MovementController
{
    static enum WorldBoundsConstraint
    {
        none,
        alwaysWithinBounds
    }

    void delegate() onLeft;
    void delegate() onUp;
    void delegate() onDown;
    void delegate() onRight;
    void delegate(Direction) onOtherDirection;

    WorldBoundsConstraint worldBoundsConstraints = WorldBoundsConstraint.none;

    private
    {
        DisplayObject targetObject;
        bool isMovement;
    }

    this(DisplayObject obj)
    {
        targetObject = obj;
    }

    override void update(double delta)
    {
        //TODO remove hal layer
        import bindbc.sdl;

        auto up = input.isPressedKey(SDLK_w);
        auto down = input.isPressedKey(SDLK_s);
        auto left = input.isPressedKey(SDLK_a);
        auto right = input.isPressedKey(SDLK_d);

        if (up && down)
        {
            up = false;
            down = false;
        }

        if (left && right)
        {
            left = false;
            right = false;
        }

        //TODO button index from config, settings
        enum moveButtonIndex = 1;
        if (input.justJoystickActive)
        {
            const lastJoystickEvent = input.lastJoystickEvent;
            if (lastJoystickEvent.button == moveButtonIndex)
            {
                if (input.justJoystickPressed)
                {
                    isMovement = true;
                }
                else
                {
                    targetObject.velocity.y = 0;
                    targetObject.velocity.x = 0;
                    isMovement = false;
                }
            }

            if (isMovement)
            {
                if (lastJoystickEvent.axis == 0)
                {
                    if (lastJoystickEvent.axisValue > 0)
                    {
                        right = true;
                    }
                    else
                    {
                        left = true;
                    }
                }
                else if (lastJoystickEvent.axis == 1)
                {
                    if (lastJoystickEvent.axisValue > 0)
                    {
                        down = true;
                    }
                    else
                    {
                        up = true;
                    }
                }
            }
        }

        if (right)
        {
            if (onRight !is null)
            {
                onRight();
            }
            targetObject.velocity.x = targetObject.speed * delta;
        }
        else if (left)
        {
            if (onLeft !is null)
            {
                onLeft();
            }
            targetObject.velocity.x = -targetObject.speed * delta;
        }
        else if (up)
        {
            if (onUp !is null)
            {
                onUp();
            }
            targetObject.velocity.y = -targetObject.speed * delta;
        }
        else if (down)
        {
            if (onDown !is null)
            {
                onDown();
            }
            targetObject.velocity.y = targetObject.speed * delta;
        }
        else
        {
            if (onOtherDirection !is null)
            {
                onOtherDirection(Direction.none);
            }
            targetObject.velocity.y = 0;
            targetObject.velocity.x = 0;
        }

        if (worldBoundsConstraints == WorldBoundsConstraint.alwaysWithinBounds)
        {
            //TODO window resizing
            const worldWidth = window.getWidth;
            const worldHeight = window.getHeight;

            const objBounds = targetObject.bounds;
            if (objBounds.x < 0)
            {
                targetObject.x = 0;
                targetObject.velocity.x = 0;
            }
            //prevent sprite jitter
        else if (objBounds.x == 0 && targetObject.velocity.x < 0)
            {
                targetObject.velocity.x = 0;
            }
            else if (objBounds.right > worldWidth)
            {
                targetObject.x = worldWidth - objBounds.width;
                targetObject.velocity.x = 0;
            }
            else if (objBounds.right == worldWidth && targetObject.velocity.x > 0)
            {
                targetObject.velocity.x = 0;
            }
            else if (objBounds.y < 0)
            {
                targetObject.y = 0;
                targetObject.velocity.y = 0;
            }
            else if (objBounds.y == 0 && targetObject.velocity.y < 0)
            {
                targetObject.velocity.y = 0;
            }
            else if (objBounds.bottom > worldHeight)
            {
                targetObject.y = worldHeight - objBounds.height;
                targetObject.velocity.y = 0;
            }
            else if (objBounds.bottom == worldHeight && targetObject.velocity.y > 0)
            {
                targetObject.velocity.y = 0;
            }
        }
    }
}
