module deltotum.display.display_object;

import deltotum.math.vector3d : Vector3D;

class DisplayObject
{

    @property double x;
    @property double y;
    @property Vector3D* velocity = new Vector3D;
    @property Vector3D* acceleration = new Vector3D;

    void draw()
    {

    }

    void update(double delta)
    {
        velocity.x += acceleration.x;
        velocity.y += acceleration.y;
        x += velocity.x;
        y += velocity.y;
    }

    void destroy()
    {

    }
}
