module dm.kit.sprites.layouts.flow_layout;

import dm.kit.sprites.sprite : Sprite;
import dm.kit.sprites.layouts.managed_layout : ManagedLayout;
import dm.math.geom.alignment : Alignment;

import Math = dm.math;

/**
 * Authors: initkfs
 */
class FlowLayout : ManagedLayout
{
    double vgap = 0;
    double hgap = 0;

    this(double hgap = 0, double vgap = 0) pure
    {
        this.hgap = hgap;
        this.vgap = vgap;
    }

    //TODO check paddng, margins, etc
    override void arrangeChildren(Sprite root)
    {
        const rootBounds = root.bounds;

        double nextX = 0;
        double nextY = 0;

        if (isFillFromStartToEnd)
        {
            nextX = rootBounds.x + root.padding.left;
            nextY = rootBounds.y + root.padding.top;
        }
        else
        {
            nextX = rootBounds.right - root.padding.right;
            nextY = rootBounds.bottom - root.padding.bottom;
        }

        double maxLineHeight = 0;
        foreach (child; root.children)
        {
            if (!child.isLayoutManaged)
            {
                continue;
            }

            const childBounds = child.bounds;

            const childHeight = childBounds.height + child.margin.height;
            if (childHeight > maxLineHeight)
            {
                maxLineHeight = childHeight;
            }

            if (isFillFromStartToEnd)
            {
                const rootRightEndX = rootBounds.right - root.padding.right;
                const newChildX = nextX + child.margin.left;
                const newChildEndX = newChildX + childBounds.width + child.margin.right;
                if (newChildEndX > rootRightEndX)
                {
                    nextX = rootBounds.x + root.padding.left;
                    //TODO line height
                    nextY += vgap + maxLineHeight;
                    maxLineHeight = 0;
                }
                else
                {
                    nextX = newChildX;
                }

                if (Math.abs(child.x - nextY) >= sizeChangeDelta)
                {
                    child.x = nextX;
                }

                if (Math.abs(child.y - nextY) >= sizeChangeDelta)
                {
                    child.y = nextY;
                }

                nextX = child.bounds.right + hgap + child.margin.right;
            }
            else
            {
                const rootLeftX = rootBounds.x + root.padding.left;
                const newChildX = nextX - childBounds.width - child.margin.right;
                if (newChildX < rootLeftX)
                {
                    nextX = rootBounds.right - root.padding.right - childBounds.width;
                    //TODO line height
                    nextY -= vgap + maxLineHeight;
                    maxLineHeight = 0;
                }
                else
                {
                    nextX = newChildX;
                }

                if (Math.abs(child.x - nextY) >= sizeChangeDelta)
                {
                    child.x = nextX;
                }

                const newChildY = nextY - childBounds.height - child.padding.bottom;
                if (Math.abs(child.y - newChildY) >= sizeChangeDelta)
                {
                    child.y = newChildY;
                }

                nextX = child.bounds.x - hgap - child.margin.left;
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

        if (hgap > 0 && childCount > 1)
        {
            childrenWidth += hgap * (childCount - 1);
        }
        return childrenWidth;
    }

    override double childrenHeight(Sprite root)
    {
        double childrenHeight = 0;
        size_t childCount;
        foreach (child; childrenForLayout(root))
        {
            childrenHeight += child.height + child.margin.height;
            childCount++;
        }

        if (vgap > 0 && childCount > 1)
        {
            childrenHeight += vgap * (childCount - 1);
        }
        return childrenHeight;
    }
}
