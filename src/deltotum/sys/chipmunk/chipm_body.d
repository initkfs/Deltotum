module deltotum.sys.chipmunk.chipm_body;

import deltotum.sys.chipmunk.base.chipm_object_wrapper : ChipmObjectWrapper;
import deltotum.sys.chipmunk.chipm_shape : ChipmShape;
import deltotum.math.vector2d : Vector2d;

import chipmunk;

/**
 * Authors: initkfs
 */
class ChipmBody : ChipmObjectWrapper!(cpBody)
{
    ChipmShape shape;

    this(cpBody* ptr) pure @safe
    {
        super(ptr);
    }

    this(double mass = 0, double moment = 0)
    {
        ptr = cpBodyNew(mass, moment);
        if (!ptr)
        {
            throw new Exception("Pointer is null");
        }
    }

    void setPosition(double x, double y)
    {
        cpBodySetPosition(ptr, cpv(x, y));
    }

    void setPosition(Vector2d p)
    {
        setPosition(p.x, p.y);
    }

    Vector2d getPosition()
    {
        cpVect pos = cpBodyGetPosition(ptr);
        return toVec(pos);
    }

    Vector2d getVelocity()
    {
        cpVect vel = cpBodyGetVelocity(ptr);
        return toVec(vel);
    }

    double angleRad()
    {
        //for clockwise -angle
        return (cpBodyGetAngle(ptr));
    }

    double angleDeg()
    {
        import Math = deltotum.math;

        return Math.radToDeg(angleRad);
    }

    override bool destroyPtr()
    {
        if (ptr)
        {
            cpBodyFree(ptr);
            return true;
        }

        return false;
    }

}
