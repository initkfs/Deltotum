module api.sims.phys2d.libs.box2d.phys_material;

struct PhysMaterial
{
    //The Coulomb (dry) friction coefficient, usually in the range [0,1].
    float friction0to1 = 0.3;

    //The coefficient of restitution (bounce) usually in the range [0,1]. https://en.wikipedia.org/wiki/Coefficient_of_restitution
    float restitution0to1 = 0;

    //The rolling resistance usually in the range [0,1].
    float rollingResistance0to1 = 0;

    //The tangent speed for conveyor belts.
    float tangentSpeed = 0;

    //Custom debug draw color.
    uint debugColor;

}