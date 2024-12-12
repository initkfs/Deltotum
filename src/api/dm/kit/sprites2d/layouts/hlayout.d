module api.dm.kit.sprites2d.layouts.hlayout;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.layouts.spaceable_layout : SpaceableLayout;
import api.math.alignment : Alignment;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class HLayout : SpaceableLayout
{
    this(double spacing = SpaceableLayout.DefaultSpacing) pure
    {
        super(spacing);
    }

    override bool alignChildren(Sprite2d root)
    {
        auto bounds = root.boundsRect;
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
            auto childBounds = child.boundsRect;

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
                if (Math.abs(child.y - newChildY) >= sizeChangeDelta)
                {
                    child.y = newChildY;
                }
            }
        }
        return true;
    }

    override double calcChildrenWidth(Sprite2d root)
    {
        if (childrenWidthProvider)
        {
            return childrenWidthProvider(root);
        }

        double calcChildrenWidth = 0;
        size_t childCount;
        foreach (child; childrenForLayout(root))
        {
            calcChildrenWidth += child.width + child.margin.width;
            childCount++;
        }

        if (spacing > 0 && childCount > 1)
        {
            calcChildrenWidth += spacing * (childCount - 1);
        }
        return calcChildrenWidth;
    }

    override double calcChildrenHeight(Sprite2d root)
    {
        double calcChildrenHeight = 0;
        foreach (child; childrenForLayout(root))
        {
            const childH = child.height + child.margin.height;
            if (childH > calcChildrenHeight)
            {
                calcChildrenHeight = childH;
            }
        }

        return calcChildrenHeight;
    }

    override double freeWidth(Sprite2d root, Sprite2d child)
    {
        return root.width - calcChildrenWidth(root) - root.padding.width;
    }

    override double freeHeight(Sprite2d root, Sprite2d child)
    {
        return root.height - child.height - root.padding.height;
    }
}
