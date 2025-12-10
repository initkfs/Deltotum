module api.sims.phys2d.libs.box2d.shapes.phys_shape;
/**
 * Authors: initkfs
 */

import api.sims.phys2d.libs.box2d.phys : Phys;
import api.sims.phys2d.libs.box2d.phys_material : PhysMaterial;
import api.math.geom2.vec2 : Vec2f;

import Math = api.math;

import std.string : toStringz;

import cbox2d;

class PhysShape : Phys
{
    string name = "PhysShape";

    PhysMaterial material;

    //The density, usually in kg/m^2.
    float initDensity = 1;

    bool enableContactEvents;

    bool enableHitEvents;

    //Only applies to dynamic bodies. These are expensive and must be carefully handled due to threading. Ignored for sensors
    bool enablePreSolveEvents;

    bool enableSensorEvents;

    //When shapes are created they will scan the environment for collision the next time step. This can significantly slow down static body creation when there are many static shapes. This is flag is ignored for dynamic and kinematic shapes which always invoke contact creation.
    bool invokeContactCreation;
    bool isSensor;
    bool updateBodyMass = true;

    protected
    {
        b2ShapeId _id;
    }

    abstract b2ShapeId createShape(b2BodyId bodyId, b2ShapeDef* def);

    void create(b2BodyId bodyId)
    {
        if (!isCreated)
        {
            b2ShapeDef shapeDef = b2DefaultShapeDef();
            shapeDef.density = initDensity;
            shapeDef.enableContactEvents = enableContactEvents;
            shapeDef.enableHitEvents = enableHitEvents;
            shapeDef.enablePreSolveEvents = enablePreSolveEvents;
            shapeDef.enableSensorEvents = enableSensorEvents;
            shapeDef.invokeContactCreation = invokeContactCreation;
            shapeDef.isSensor = isSensor;
            shapeDef.updateBodyMass = updateBodyMass;

            b2SurfaceMaterial bMaterial;
            bMaterial.customColor = material.debugColor;
            bMaterial.friction = material.friction0to1;
            bMaterial.restitution = material.restitution0to1;
            bMaterial.rollingResistance = material.rollingResistance0to1;
            bMaterial. tangentSpeed = material.tangentSpeed;
            bMaterial.userMaterialId = 0;

            shapeDef.material = bMaterial;

            _id = createShape(bodyId, &shapeDef);

            isCreated = true;
        }

    }

    void dispose(bool updateBodyMass = true)
    {
        //This destroys all shapes and joints attached to the body. Do not keep references to the associated shapes and joints.
        b2DestroyShape(_id, updateBodyMass);
    }

    b2ShapeId id() => _id;
}
