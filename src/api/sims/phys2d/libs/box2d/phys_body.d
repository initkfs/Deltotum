module api.sims.phys2d.libs.box2d.phys_body;
/**
 * Authors: initkfs
 */

import api.sims.phys2d.libs.box2d.phys : Phys;
import api.sims.phys2d.libs.box2d.shapes.phys_shape : PhysShape;
import api.sims.phys2d.libs.box2d.shapes.phys_circle_shape : PhysCircleShape;
import api.math.geom2.vec2 : Vec2f;

import Math = api.math;

import std.string : toStringz;

import cbox2d;

class PhysBody : Phys
{
    //Up to 31 characters (excluding null termination)
    string name = "PhysBody";

    protected
    {
        b2BodyId _id;
    }

    enum BodyType
    {
        staticBody = 0,
        kinematicBody = 1,
        dynamicBody = 2,
    }

    BodyType type = BodyType.dynamicBody;

    Vec2f initPosition;

    //The initial linear velocity of the body's origin. Usually in meters per second.
    Vec2f velocity;
    //reduce the linear velocity.
    float velocityDamping = 1;

    //Radians per second.
    float angularVelocity = 0;
    //Reduce angular velocity.
    float angularDamping = 1;

    float initRotationDeg = 0;

    //Set to false if body should never fall asleep.
    bool isEnableSleep = true;

    // Bypass rotational speed limits. Should only be used for circular objects, like wheels.
    bool isAllowFastRotation;

    bool isFixedRotation;

    //Is this body initially awake or sleeping?
    bool isInitAwake = true;

    //high speed object that performs continuous collision detection. They may interfere with joint constraints.
    bool isInitBullet;

    //A disabled body does not move or collide.
    bool isInitDisabled;

    void create(b2WorldId worldId)
    {
        if (!isCreated)
        {
            b2BodyDef bodyDef = b2DefaultBodyDef();

            bodyDef.name = name.toStringz;
            bodyDef.type = toNativeType(type);
            bodyDef.position = cast(b2Vec2) initPosition;
            bodyDef.linearVelocity = cast(b2Vec2) velocity;
            bodyDef.linearDamping = velocityDamping;
            bodyDef.angularVelocity = angularVelocity;
            bodyDef.angularDamping = angularDamping;

            bodyDef.enableSleep = isEnableSleep;
            bodyDef.allowFastRotation = isAllowFastRotation;
            bodyDef.fixedRotation = isFixedRotation;
            bodyDef.isAwake = isInitAwake;
            bodyDef.isBullet = isInitBullet;
            bodyDef.isEnabled = !isInitDisabled;

            const rotRad = Math.degToRad(initRotationDeg);

            b2CosSin cs = b2ComputeCosSin(rotRad);

            b2Rot brotation = b2Rot(cs.cosine, cs.sine);
            bodyDef.rotation = brotation;

            _id = b2CreateBody(worldId, &bodyDef);

            isCreated = true;
        }
    }

    void createShapeCircle(float radius = 1, Vec2f center = Vec2f.init, scope void delegate(
            PhysCircleShape) onShape = null)
    {
        scope shape = new PhysCircleShape(radius, center);
        if (onShape)
        {
            onShape(shape);
        }
        shape.create(_id);
    }

    PhysCircleShape createShapeCircleNew(scope void delegate(PhysCircleShape) onShape, float radius = 1, Vec2f center = Vec2f
            .init)
    {
        assert(isCreated);

        auto shape = new PhysCircleShape(radius, center);
        onShape(shape);
        shape.create(_id);
        return shape;
    }

    void applyForce(Vec2f force, Vec2f point, bool wake = true)
    {
        //force the world force vector, usually in newtons (N).
        b2Body_ApplyForce(_id, cast(b2Vec2) force, cast(b2Vec2) point, wake);
    }

    void applyForceToCenter(Vec2f force, bool wake = true)
    {
        b2Body_ApplyForceToCenter(_id, cast(b2Vec2) force, wake);
    }

    //This should be used for one-shot impulses. 
    void applyImpulseLinear(Vec2f force, Vec2f point, bool wake = true)
    {
        b2Body_ApplyLinearImpulse(_id, cast(b2Vec2) force, cast(b2Vec2) point, wake);
    }

    void applyImpulseLinearCenter(Vec2f force, bool wake = true)
    {
        b2Body_ApplyLinearImpulseToCenter(_id, cast(b2Vec2) force, wake);
    }

    void applyImpulseAngular(float impulse = 1, bool wake = true)
    {
        //The impulse is ignored if the body is not awake.
        //This should be used for one-shot impulses
        b2Body_ApplyAngularImpulse(_id, impulse, wake);
    }

    void applyTorque(float torque, bool wake = true)
    {
        //This affects the angular velocity without affecting the linear velocity.
        b2Body_ApplyTorque(_id, torque, wake);
    }

    void enableContactEvents(bool isEvents)
    {
        //changing this at runtime may cause mismatched begin/end touch events
        b2Body_EnableContactEvents(_id, isEvents);
    }

    void enableHitEvents(bool isEvents)
    {
        b2Body_EnableHitEvents(_id, isEvents);
    }

    void applyMassFromShape()
    {
        b2Body_ApplyMassFromShapes(_id);
    }

    void contactData(size_t capacity)
    {
        b2ContactData[] contactData = new b2ContactData[capacity];
        int count = b2Body_GetContactData(_id, contactData.ptr, cast(int) capacity);
        if (count == 0 || count > contactData.length)
        {
            return;
        }

        foreach (contact; contactData[0 .. count])
        {
            //TODO delegates
            b2Manifold manifold = contact.manifold;
            b2ShapeId shapeIdA = contact.shapeIdA;
            b2ShapeId shapeIdB = contact.shapeIdB;
        }
    }

    void joints(size_t capacity)
    {
        b2JointId[] joints = new b2JointId[capacity];
        int count = b2Body_GetJoints(_id, joints.ptr, cast(int) capacity);
        if (count == 0 || count > joints.length)
        {
            return;
        }

        foreach (joint; joints[0 .. count])
        {
            //TODO delegates
        }
    }

    void shapes(size_t capacity)
    {
        b2ShapeId[] targets = new b2ShapeId[capacity];
        int count = b2Body_GetShapes(_id, targets.ptr, cast(int) capacity);
        if (count == 0 || count > targets.length)
        {
            return;
        }

        foreach (shape; targets[0 .. count])
        {
            //TODO delegates
        }
    }

    Vec2f position() => cast(Vec2f) b2Body_GetPosition(_id);

    float rotationDeg()
    {
        b2Rot rotation = b2Body_GetRotation(_id);
        return Math.radToDeg(b2Rot_GetAngle(rotation));
    }

    protected b2BodyType toNativeType(BodyType type)
    {
        final switch (type) with (BodyType)
        {
            case staticBody:
                return b2BodyType.b2_staticBody;
            case kinematicBody:
                return b2BodyType.b2_kinematicBody;
            case dynamicBody:
                return b2BodyType.b2_dynamicBody;
        }
    }

    protected BodyType fromNativeType(b2BodyType type)
    {
        final switch (type) with (b2BodyType)
        {
            case b2_staticBody:
                return BodyType.staticBody;
            case b2_kinematicBody:
                return BodyType.kinematicBody;
            case b2_dynamicBody:
                return BodyType.dynamicBody;
            case b2_bodyTypeCount:
                return BodyType.staticBody;
        }
    }

    bool isAwake() => b2Body_IsAwake(_id);
    void isAwake(bool value)
    {
        //Putting a body to sleep will put the entire island of bodies touching this body to sleep, which can be expensive and possibly unintuitive.
        b2Body_SetAwake(_id, value);
    }

    void setBullet(bool value)
    {
        b2Body_SetBullet(_id, value);
    }

    void setGravityScale(float value)
    {
        b2Body_SetGravityScale(_id, value);
    }

    void setMass()
    {
        b2MassData data;
        //Normally this is computed automatically using the shape geometry and density
        b2Body_SetMassData(_id, data);
    }

    void setTransform(Vec2f position, b2Rot rotation)
    {
        //This acts as a teleport and is fairly expensive.
        b2Body_SetTransform(_id, cast(b2Vec2) position, rotation);
    }

    void setType(BodyType type)
    {
        //This is an expensive operation.
        b2Body_SetType(_id, toNativeType(type));
    }

    void dispose()
    {
        //This destroys all shapes and joints attached to the body. Do not keep references to the associated shapes and joints.
        b2DestroyBody(_id);
    }

    b2BodyId id() => _id;
}
