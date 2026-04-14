module api.dm.kit.sprites3d.pipelines.env.blend_group;

import api.dm.kit.sprites3d.pipelines.env.env_group : EnvGroup;
import api.dm.kit.sprites2d.sprite2d: Sprite2d;
import api.dm.kit.sprites3d.sprite3d : Sprite3d;

/**
 * Authors: initkfs
 */

/** 
 * Display all opaque objects.
 * Sort transparent objects by distance.
 * Draw transparent objects in sorted order.
 */
class BlendGroup : EnvGroup
{
    bool isNeedSortByZ;
    bool delegate(Sprite2d, Sprite2d) childComparatorZ;

    this()
    {
        isBlend = true;
    }

    override void initialize()
    {
        super.initialize;

        if (!childComparatorZ)
        {
            childComparatorZ = (a, b) {
                Sprite3d aSprite = cast(Sprite3d) a;
                Sprite3d bSprite = cast(Sprite3d) b;
                if (!aSprite || !bSprite)
                {
                    //TODO 0?
                    return false;
                }
                return aSprite.z < bSprite.z;
            };
        }
    }

    override void update(float dt)
    {
        super.update(dt);

        if (isNeedSortByZ && childComparatorZ)
        {
            import std.algorithm.sorting : sort;

            children.sort!(childComparatorZ);

            isNeedSortByZ = false;
        }
    }
}
