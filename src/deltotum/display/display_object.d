module deltotum.display.display_object;

import deltotum.application.components.uni.uni_component : UniComponent;

import deltotum.math.vector3d : Vector3D;

/**
 * Authors: initkfs
 */
abstract class DisplayObject : UniComponent
{

    @property double x = 0;
    @property double y = 0;
    @property double width = 0;
    @property double height = 0;
    @property Vector3D* velocity = new Vector3D;
    @property Vector3D* acceleration = new Vector3D;
    @property bool isRedraw = false;

    void drawContent() {

    }

    final bool draw()
    {
        //TODO layer
        drawContent;
        return true;
    }

    void requestRedraw(){
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

    void destroy()
    {

    }
}
