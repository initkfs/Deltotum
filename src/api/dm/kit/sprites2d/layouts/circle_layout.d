module api.dm.kit.sprites2d.layouts.circle_layout;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.layouts.managed_layout : ManagedLayout;
import api.math.pos2.alignment : Alignment;

/**
 * Authors: initkfs
 */
class CircleLayout : ManagedLayout
{
    float radius = 0;
    float startAngle = 0;

    this(float radius = 0, float startAngle = 0) pure
    {
        this.radius = radius;
        this.startAngle = startAngle;

        isAlignBeforeResize = true;
        isAlignAfterResize = false;
    }

    //TODO reverse, paddng, margins
    override bool alignChildren(Sprite2d root)
    {
        if (radius <= 0)
        {
            return false;
        }

        import Math = api.dm.math;
        import api.math.geom2.vec2 : Vec2f;
        import std.range.primitives : walkLength;

        auto children = childrenForLayout(root);
        const childCount = children.walkLength;
        if (childCount == 0)
        {
            return false;
        }

        const float fullAngle = 360.0;

        const float angleDegStep = fullAngle / childCount;

        const rootBounds = root.boundsRect;
        const startX = rootBounds.center.x;
        const startY = rootBounds.center.y;

        float nextDeg = isFillStartToEnd ? startAngle : (fullAngle - startAngle);
        foreach (child; children)
        {
            const childBounds = child.boundsRect;
            const pos = Vec2f.fromPolarDeg(nextDeg, radius);
            child.x = child.margin.left + startX + pos.x - childBounds.halfWidth - child
                .margin.right;
            child.y = child.margin.top + startY + pos.y - childBounds.halfHeight - child
                .margin.bottom;

            if (isFillStartToEnd)
            {
                nextDeg += angleDegStep;
            }
            else
            {
                nextDeg -= angleDegStep;
            }
        }
        return true;
    }

    //FIXME padding is not always calculated correctly, check on an odd number
    override float calcChildrenWidth(Sprite2d root)
    {
        float minX = 0;
        float maxX = 0;
        foreach (child; childrenForLayout(root))
        {
            if (minX == 0 || child.x < minX)
            {
                minX = child.x;
            }

            if (maxX == 0 || child.boundsRect.right > maxX)
            {
                maxX = child.boundsRect.right;
            }
        }

        if (maxX > minX)
        {
            return maxX - minX;
        }

        return 0;
    }

    override float calcChildrenHeight(Sprite2d root)
    {
        const rootBounds = root.boundsRect;

        float minY = 0;
        float maxY = 0;
        foreach (child; childrenForLayout(root))
        {
            if (minY == 0 || child.y < minY)
            {
                minY = child.y;
            }

            if (maxY == 0 || child.boundsRect.bottom > maxY)
            {
                maxY = child.boundsRect.bottom;
            }
        }

        if (maxY > minY)
        {
            const minDt = minY - rootBounds.y - root.padding.top;
            if (minDt > 0)
            {
                minY -= minDt;
            }

            if (minDt > 0 && minDt)
            {
                maxY += minDt;
            }

            return maxY - minY;
        }

        return 0;
    }
}
