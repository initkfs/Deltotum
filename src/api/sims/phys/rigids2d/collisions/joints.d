module api.sims.phys.rigids2d.collisions.joints;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.math.geom2.rect2 : Rect2f;
import api.math.geom2.circle2 : Circle2f;

import api.sims.phys.rigids2d.collisions.contacts;
import api.sims.phys.rigids2d.collisions.contact_checker;
import api.sims.phys.rigids2d.collisions.contacts;

import api.math.geom2.vec2 : Vec2f;
import Math = api.math;

/**
 * Authors: initkfs
 */

class DistanceJoint : Sprite2d
{

    Sprite2d bodyA;
    Vec2f localAnchorA;

    Sprite2d bodyB;
    Vec2f localAnchorB;

    float length = 200;
    float stiffness = 0.5;

    bool isDrawJoint = true;

    this(Sprite2d a, Sprite2d b)
    {
        bodyA = a;
        bodyB = b;

        localAnchorA = Vec2f(0, 0);
        localAnchorB = Vec2f(0, 0);
    }

    override void drawContent()
    {
        super.drawContent;

        if(!isDrawJoint){
            return;
        }

        //TODO rotate
        Vec2f worldAnchorA = bodyA.pos + localAnchorA;
        Vec2f worldAnchorB = bodyB.pos + localAnchorB;

        graphic.line(worldAnchorA, worldAnchorB);
    }

    override void updatePhys(out float dx, out float dy, float dt)
    {
        super.updatePhys(dx, dy, dt);

        //TODO rotate
        Vec2f worldAnchorA = bodyA.pos + localAnchorA;
        Vec2f worldAnchorB = bodyB.pos + localAnchorB;

        Vec2f delta = worldAnchorB - worldAnchorA;
        float currentLength = delta.length;

        if (Math.abs(currentLength - length) < 0.001f)
            return;

        Vec2f normal = (currentLength > 0) ? delta.normalize : Vec2f(1, 0);

        float correction = currentLength - length;

        applyCorrection(normal, correction, dt);
    }

    void applyCorrection(Vec2f normal, float correction, float dt)
    {
        Vec2f ra = (bodyA.pos + localAnchorA) - bodyA.pos;
        Vec2f rb = (bodyB.pos + localAnchorB) - bodyB.pos;

        float raCrossN = ra.cross(normal);
        float rbCrossN = rb.cross(normal);

        float invMassA = bodyA.invMass + raCrossN * raCrossN * bodyA.invInertia;
        float invMassB = bodyB.invMass + rbCrossN * rbCrossN * bodyB.invInertia;
        float totalInvMass = invMassA + invMassB;

        if (totalInvMass < 1e-7f)
            return;

        float lambda = -(correction * stiffness) / (totalInvMass);
        Vec2f impulse = normal.scale(lambda);

        bodyA.velocity -= impulse.scale(bodyA.invMass);
        bodyB.velocity += impulse.scale(bodyB.invMass);

        bodyA.angularVelocity -= bodyA.invInertia * ra.cross(impulse);
        bodyB.angularVelocity += bodyB.invInertia * rb.cross(impulse);
    }
}
