module deltotum.physics.movement.complex_movement_controller;

import deltotum.physics.movement.movement_controller : MovementController;

import deltotum.display.display_object : DisplayObject;
import deltotum.physics.direction : Direction;

/**
 * Authors: initkfs
 */
class ComplexMovementController : DisplayObject
{
    static enum WorldBoundsConstraint
    {
        none,
        alwaysWithinBounds
    }

    @property void delegate() onLeft;
    @property void delegate() onUp;
    @property void delegate() onDown;
    @property void delegate() onRight;
    @property void delegate(Direction) onOtherDirection;

    @property worldBoundsConstraints = WorldBoundsConstraint.none;

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
        super.update(delta);
        //TODO remove hal layer
        import bindbc.sdl;

        auto up = input.pressed(SDLK_w);
        auto down = input.pressed(SDLK_s);
        auto left = input.pressed(SDLK_a);
        auto right = input.pressed(SDLK_d);

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
            if (input.lastJoystickButton == moveButtonIndex)
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
                if (input.lastJoystickAxis == 0)
                {
                    if (input.lastJoystickAxisValue > 0)
                    {
                        right = true;
                    }
                    else
                    {
                        left = true;
                    }
                }
                else if (input.lastJoystickAxis == 1)
                {
                    if (input.lastJoystickAxisValue > 0)
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

    override void destroy()
    {
        super.destroy;
        targetObject = null;
    }
}
