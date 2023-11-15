module dm.kit.sprites.layouts.hlayout;

import dm.kit.sprites.sprite : Sprite;
import dm.kit.sprites.layouts.managed_layout : ManagedLayout;
import dm.math.geom.alignment : Alignment;

import Math = dm.math;

/**
 * Authors: initkfs
 */
class HLayout : ManagedLayout
{
    double spacing = 0;

    this(double spacing = 0) pure
    {
        this.spacing = spacing;
    }

    override void arrangeChildren(Sprite root)
    {
        auto bounds = root.bounds;
        double nextX = 0;
        if (isFillFromStartToEnd)
        {
            nextX = bounds.x + root.padding.left;
        }
        else
        {
            nextX = bounds.right - root.padding.right;
        }

        foreach (child; root.children)
        {
            if (!child.isLayoutManaged)
            {
                continue;
            }
            auto childBounds = child.bounds;

            if (isFillFromStartToEnd)
            {
                const childX = nextX + child.margin.left;
                if (Math.abs(child.x - childX) >= sizeChangeDelta)
                {
                    child.x = childX;
                }

                nextX = child.x + childBounds.width + child.margin.right + spacing;
            }
            else
            {
                const childX = nextX - child.margin.right - childBounds.width;
                if (Math.abs(child.x - childX) >= sizeChangeDelta)
                {
                    child.x = childX;
                }
                nextX = child.x - child.margin.left - spacing;
            }

            if (isAlignY || child.alignment == Alignment.y)
            {
                alignY(root, child);
            }
            else
            {
                const newChildY = root.y + root.padding.top + child.margin.top;
                if(Math.abs(child.y - newChildY) >= sizeChangeDelta){
                    child.y = newChildY;
                }
            }
        }
    }

    override double childrenWidth(Sprite root)
    {
        double childrenWidth = 0;
        size_t childCount;
        foreach (child; childrenForLayout(root))
        {
            childrenWidth += child.width + child.margin.width;
            childCount++;
        }

        if (spacing > 0 && childCount > 1)
        {
            childrenWidth += spacing * (childCount - 1);
        }
        return childrenWidth;
    }

    override double childrenHeight(Sprite root)
    {
        double childrenHeight = 0;
        foreach (child; childrenForLayout(root))
        {
            const childH = child.height + child.margin.height;
            if (childH > childrenHeight)
            {
                childrenHeight = childH;
            }
        }

        return childrenHeight;
    }

    override double freeWidth(Sprite root, Sprite child)
    {
        return root.width - childrenWidth(root) - root.padding.width;
    }

    override double freeHeight(Sprite root, Sprite child)
    {
        return root.height - child.height - root.padding.height;
    }
}
