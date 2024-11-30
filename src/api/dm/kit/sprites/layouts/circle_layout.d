module api.dm.kit.sprites.layouts.circle_layout;

import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.sprites.layouts.managed_layout : ManagedLayout;
import api.math.alignment : Alignment;

/**
 * Authors: initkfs
 */
class CircleLayout : ManagedLayout
{
    double radius = 0;
    double startAngle = 0;

    this(double radius = 0) pure
    {
        this.radius = radius;
        isAlignBeforeResize = true;
        isAlignAfterResize = false;
    }

    //TODO reverse, paddng, margins
    override bool alignChildren(Sprite root)
    {
        if (radius <= 0)
        {
            return false;
        }

        import Math = api.dm.math;
        import api.math.geom2.vec2 : Vec2d;
        import std.range.primitives : walkLength;

        auto children = childrenForLayout(root);
        const childCount = children.walkLength;
        if (childCount == 0)
        {
            return false;
        }

        const double angleDegStep = 360.0 / childCount;

        const rootBounds = root.boundsRect;
        const startX = rootBounds.center.x;
        const startY = rootBounds.center.y;

        double nextDeg = startAngle;
        foreach (child; children)
        {
            const childBounds = child.boundsRect;
            const pos = Vec2d.fromPolarDeg(nextDeg, radius);
            child.x = child.margin.left + startX + pos.x - childBounds.halfWidth - child
                .margin.right;
            child.y = child.margin.top + startY + pos.y - childBounds.halfHeight - child
                .margin.bottom;
            nextDeg += angleDegStep;
        }
        return true;
    }

    //FIXME padding is not always calculated correctly, check on an odd number
    override double childrenWidth(Sprite root)
    {
        double minX = 0;
        double maxX = 0;
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

    override double childrenHeight(Sprite root)
    {
        const rootBounds = root.boundsRect;

        double minY = 0;
        double maxY = 0;
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
