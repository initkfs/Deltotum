module api.sims.phys2d.libs.box2d.phys_world;
/**
 * Authors: initkfs
 */

import api.sims.phys2d.libs.box2d.phys : Phys;
import api.sims.phys2d.libs.box2d.phys_body : PhysBody;
import api.math.geom2.vec2 : Vec2f;

import cbox2d;

class PhysWorld : Phys
{
    protected
    {
        b2WorldId _id;
    }

    bool isCreated;

    Vec2f gravity = Vec2f(0, -5);
    int subStepCount = 4;

    bool isEnableSleep = true;

    this()
    {

    }

    void create()
    {
        if (!isCreated)
        {
            b2WorldDef worldDef = b2DefaultWorldDef();

            worldDef.gravity = cast(b2Vec2) gravity;
            worldDef.enableSleep = isEnableSleep;

            _id = b2CreateWorld(&worldDef);

            isCreated = true;
        }

    }

    PhysBody createBody(scope void delegate(PhysBody) onBody)
    {
        assert(isCreated);
        PhysBody newBody = new PhysBody;
        onBody(newBody);
        newBody.create(_id);
        return newBody;
    }

    void update(float dt)
    {
        b2World_Step(_id, dt, subStepCount);
    }

    b2WorldId id() => _id;

    void dispose()
    {
        //This efficiently destroys all bodies, shapes, and joints in the simulation.
        b2DestroyWorld(_id);
    }
}

unittest
{
    //1.0 / 60
    const float dt = 0.5;

    auto world = new PhysWorld;
    world.create;
    scope (exit)
    {
        world.dispose;
    }

    auto pBody = world.createBody((b) { b.initPosition = Vec2f(0, 5); });

    pBody.createShapeCircle(5);

    float lastPosition = 5;
    foreach (ti; 0 .. 5)
    {
        world.update(dt);

        b2Vec2 position = b2Body_GetPosition(pBody.id);
        assert(position.y < lastPosition);
        lastPosition = position.y;
    }

}
