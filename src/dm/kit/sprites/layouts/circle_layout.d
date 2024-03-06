module dm.kit.sprites.layouts.circle_layout;

import dm.kit.sprites.sprite : Sprite;
import dm.kit.sprites.layouts.managed_layout : ManagedLayout;
import dm.math.alignment : Alignment;

/**
 * Authors: initkfs
 */
class CircleLayout : ManagedLayout
{
    double radius = 0;

    this(double radius = 0) pure
    {
        this.radius = radius;
        isArrangeBeforeResize = true;
        isArrangeAfterResize = false;
    }

    //TODO reverse, paddng, margins
    override void arrangeChildren(Sprite root)
    {
        if (radius <= 0)
        {
            return;
        }

        import Math = dm.math;
        import dm.math.vector2 : Vector2;
        import std.range.primitives : walkLength;

        auto children = childrenForLayout(root);
        const childCount = children.walkLength;
        if (childCount == 0)
        {
            return;
        }

        const int angleDegStep = 360 / childCount;

        const rootBounds = root.bounds;
        const startX = rootBounds.x + root.padding.left;
        const startY = rootBounds.y + root.padding.top;

        int nextDeg = 0;
        foreach (child; children)
        {
            const pos = Vector2.fromPolarDeg(nextDeg, radius);
            child.x = startX + radius + pos.x; //- child.width / 2;
            child.y = startY + radius + pos.y; //- child.height / 2;
            nextDeg += angleDegStep;
        }
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

            if (maxX == 0 || child.bounds.right > maxX)
            {
                maxX = child.bounds.right;
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
        const rootBounds = root.bounds;

        double minY = 0;
        double maxY = 0;
        foreach (child; childrenForLayout(root))
        {
            if (minY == 0 || child.y < minY)
            {
                minY = child.y;
            }

            if (maxY == 0 || child.bounds.bottom > maxY)
            {
                maxY = child.bounds.bottom;
            }
        }

        if (maxY > minY)
        {
            const minDt = minY - rootBounds.y - root.padding.top;
            if (minDt > 0)
            {
                minY -= minDt;
            }

            if(minDt > 0 && minDt){
                maxY += minDt;
            }

            return maxY - minY;
        }

        return 0;
    }
}
