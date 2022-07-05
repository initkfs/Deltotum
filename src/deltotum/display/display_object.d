module deltotum.display.display_object;

import deltotum.application.components.uni.uni_component : UniComponent;

import deltotum.math.vector3d : Vector3D;
import deltotum.math.rect : Rect;

/**
 * Authors: initkfs
 */
abstract class DisplayObject : UniComponent
{

    @property double x = 0;
    @property double y = 0;
    @property double width = 0;
    @property double height = 0;
    @property Vector3D* velocity;
    @property Vector3D* acceleration;
    @property bool isRedraw = false;

    this()
    {
        //use initialization in constructor
        velocity = new Vector3D;
        acceleration = new Vector3D;
    }

    void drawContent()
    {

    }

    final bool draw()
    {
        //TODO layer
        drawContent;
        return true;
    }

    void requestRedraw()
    {
        isRedraw = true;
    }

    void update(double delta)
    {
        draw;

        velocity.x += acceleration.x * delta;
        velocity.y += acceleration.y * delta;
        x += velocity.x * delta;
        y += velocity.y * delta;
    }

    Rect bounds()
    {
        const Rect bounds = {x, y, width, height};
        return bounds;
    }

    void destroy()
    {

    }
}
