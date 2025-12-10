module api.sims.phys2d.libs.box2d.shapes.phys_circle_shape;
/**
 * Authors: initkfs
 */

import api.sims.phys2d.libs.box2d.shapes.phys_shape : PhysShape;
import api.sims.phys2d.libs.box2d.phys_material : PhysMaterial;
import api.math.geom2.vec2 : Vec2f;

import Math = api.math;

import cbox2d;

class PhysCircleShape : PhysShape
{
    float radius = 0;
    Vec2f center;
    
    this(float radius = 1, Vec2f center = Vec2f.init)
    {
        name = "PhysCircle";

        this.center = center;
        this.radius = radius;
    }

    override b2ShapeId createShape(b2BodyId bodyId, b2ShapeDef* def)
    {
        b2Circle circle;
        circle.center = cast(b2Vec2) center;
        circle.radius = radius;

        return b2CreateCircleShape(bodyId, def, &circle);
    }
}
