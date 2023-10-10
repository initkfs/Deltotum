module deltotum.sys.chipmunk.chipm_space;

import deltotum.sys.chipmunk.base.chipm_object_wrapper : ChipmObjectWrapper;

import deltotum.sys.chipmunk.chipm_shape : ChipmShape;
import deltotum.sys.chipmunk.chipm_body : ChipmBody;

import deltotum.math.vector2d : Vector2d;

import chipmunk;

/**
 * Authors: initkfs
 */
class ChipmSpace : ChipmObjectWrapper!(cpSpace)
{
    double width = 0;
    double height = 0;

    protected
    {
        ChipmShape[] shapes;
        ChipmBody[] bodies;
    }

    this(cpSpace* ptr) pure @safe
    {
        super(ptr);
    }

    this()
    {
        ptr = cpSpaceNew;
        if (!ptr)
        {
            throw new Exception("Pointer is null");
        }
    }

    ChipmShape newStaticSegmentShape(Vector2d start, Vector2d end, double radius = 0)
    {
        auto ptr = cpSegmentShapeNew(getStaticBodyPtr, fromVec(start), fromVec(end), radius);
        auto shape = new ChipmShape(ptr);
        addShape(ptr);
        return shape;
    }

    // Vector2d spaceToWorld(double x, double y)
    // {
    //     const newY = height > 0 ? height - y : y;
    //     return Vector2d(x, newY);
    // }

    // Vector2d spaceToWorld(Vector2d p)
    // {
    //     return spaceToWorld(p.x, p.y);
    // }

    // Vector2d worldToSpace(double x, double y)
    // {
    //     return spaceToWorld(x, y);
    // }

    // Vector2d worldToSpace(Vector2d p)
    // {
    //     return spaceToWorld(p.x, p.y);
    // }

    void step(double stepValue)
    {
        cpSpaceStep(ptr, stepValue);
    }

    void addShape(cpShape* shape)
    {
        cpSpaceAddShape(ptr, shape);
    }

    void removeShape(cpShape* shape)
    {
        cpSpaceRemoveShape(ptr, shape);
    }

    void addBody(cpBody* body)
    {
        cpSpaceAddBody(ptr, body);
    }

    void removeBody(cpBody* body)
    {
        cpSpaceRemoveBody(ptr, body);
    }

    void setGravityNorm(Vector2d g)
    {
        setGravityNorm(g.x, g.y);
    }

    void setGravityNorm(double x = 0, double y = 0)
    {
        //invert y for consistency with SDL
        cpVect gravity = cpv(x, -y);
        cpSpaceSetGravity(ptr, gravity);
    }

    cpCollisionHandler* addCollisionHandler(ulong type1 = 0, ulong type2 = 0)
    {
        cpCollisionHandler* handler = cpSpaceAddCollisionHandler(ptr, type1, type2);
        return handler;
    }

    cpCollisionHandler* addWildcardHandler(ulong type = 0)
    {
        cpCollisionHandler* handler = cpSpaceAddWildcardHandler(ptr, type);
        return handler;
    }

    void setIterations(int value)
    {
        cpSpaceSetIterations(ptr, value);
    }

    void setCollisionSlop(double value)
    {
        cpSpaceSetCollisionSlop(ptr, value);
    }

    void setSleepTimeThreshold(double value){
        cpSpaceSetSleepTimeThreshold(ptr, value);
    }

    cpBody* getStaticBodyPtr()
    {
        auto bodyPtr = cpSpaceGetStaticBody(ptr);
        return bodyPtr;
    }

    ChipmBody getStaticBody()
    {
        auto bodyPtr = cpSpaceGetStaticBody(ptr);
        return new ChipmBody(bodyPtr);
    }

    override bool disposePtr()
    {
        // foreach (ChipmShape shape; shapes)
        // {
        //     shape.disposePtr;
        // }

        shapes = null;

        if (ptr)
        {
            cpSpaceFree(ptr);
            return true;
        }

        return false;
    }

    double momentForCircle(double mass, double innerRadius, double outerRadius, Vector2d offset = Vector2d(0, 0))
    {
        double value = cpMomentForCircle(mass, innerRadius, outerRadius, fromVec(offset));
        return value;
    }

}
