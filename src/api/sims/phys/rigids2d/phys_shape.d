module api.sims.phys.rigids2d.phys_shape;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;

enum PhysShape
{
    rect,
    circle,
}

float inertiaRect(Sprite2d target, float scale = 0.0001)
{
    return (1.0f / 12.0f) * target.mass * (
        target.boundsRect.width * target.boundsRect.width + target.boundsRect.height * target
            .boundsRect.height) * scale;
}

float inertiaCircle(Sprite2d target, float scale = 0.0001)
{
    return 0.5f * target.mass * target.halfWidth * target.halfWidth * scale;
}

//TODO cache
void calcInertia(Sprite2d target)
{
    auto mech = target.domains.mech;

    float result = 0;
    final switch (mech.physShape) with (PhysShape)
    {
        case rect:
            result = inertiaRect(target);
            break;
        case circle:
            result = inertiaCircle(target);
            break;
    }

    mech.inertia = result;
}
