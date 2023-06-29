module deltotum.sys.chipmunk.chipm_shape;

import deltotum.sys.chipmunk.base.chipm_object_wrapper : ChipmObjectWrapper;
import deltotum.sys.chipmunk.chipm_body : ChipmBody;

import deltotum.math.vector2d : Vector2d;
import deltotum.math.shapes.rect2d : Rect2d;

import chipmunk;

/**
 * Authors: initkfs
 */
class ChipmShape : ChipmObjectWrapper!(cpShape)
{
    this(cpShape* ptr) pure @safe
    {
        super(ptr);
    }

    Rect2d getBounds()
    {
        cpBB b = cpShapeGetBB(ptr);
        return Rect2d(b.l, b.t, b.r - b.l, b.b - b.t);
    }

    override bool destroyPtr()
    {
        if (ptr)
        {
            cpShapeFree(ptr);
            return true;
        }
        return false;
    }

    static ChipmShape newCircleShape(ChipmBody physBody, double radius, Vector2d offset = Vector2d(0, 0))
    {
        auto ptr = cpCircleShapeNew(physBody.getObject, radius, fromVec(offset));
        auto shape = new ChipmShape(ptr);
        return shape;
    }

    static ChipmShape newBoxShape(ChipmBody physBody, double width, double height, double radius = 0)
    {
        auto ptr = cpBoxShapeNew(physBody.getObject, width, height, radius);
        return new ChipmShape(ptr);
    }

    void setFriction(double value)
    {
        cpShapeSetFriction(ptr, value);
    }

    void setElasticity(double value)
    {
        cpShapeSetElasticity(ptr, value);
    }

    void setCollisionType(ulong type){
        cpShapeSetCollisionType(ptr, type);
    }

    void setFilter(cpShapeFilter f){
        cpShapeSetFilter(ptr, f);
    }

    void setUserData(void* data){
        cpShapeSetUserData(ptr, data);
    }

    void getUserData(out void* data){
        data = cpShapeGetUserData(ptr);
    }
}
