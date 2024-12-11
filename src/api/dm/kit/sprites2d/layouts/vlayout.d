module api.dm.kit.sprites2d.layouts.vlayout;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.layouts.spaceable_layout: SpaceableLayout;
import api.math.alignment : Alignment;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class VLayout : SpaceableLayout
{
    this(double spacing = SpaceableLayout.DefaultSpacing) pure
    {
        super(spacing);
    }

    override bool alignChildren(Sprite2d root)
    {
        auto bounds = root.boundsRect;
        double nextY = 0;
        if (isFillFromStartToEnd)
        {
            nextY = bounds.y + root.padding.top;
        }
        else
        {
            nextY = bounds.bottom - root.padding.bottom;
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
                const newChildY = nextY + child.margin.top;
                if (Math.abs(child.y - newChildY) > sizeChangeDelta)
                {
                    child.y = newChildY;
                }
                nextY = child.y + childBounds.height + child.margin.bottom + spacing;
            }
            else
            {
                const newChildY = nextY - child.margin.bottom - childBounds.height;
                if (Math.abs(child.y - newChildY) > sizeChangeDelta)
                {
                    child.y = newChildY;
                }
                nextY = child.y + child.margin.top - spacing;
            }

            if (isAlignX || child.alignment == Alignment.x)
            {
                alignX(root, child);
            }
            else
            {
                const newChildX = root.x + root.padding.left + child.margin.left;
                if (Math.abs(newChildX - child.x) > sizeChangeDelta)
                {
                    child.x = newChildX;
                }
            }
        }
        return true;
    }

    override double childrenWidth(Sprite2d root)
    {
        double childrenWidth = 0;
        foreach (child; childrenForLayout(root))
        {
            const chWidth = child.width + child.margin.width;
            if (chWidth > childrenWidth)
            {
                childrenWidth = chWidth;
            }
        }

        return childrenWidth;
    }

    override double childrenHeight(Sprite2d root)
    {
        double childrenHeight = 0;
        size_t childCount;
        foreach (child; childrenForLayout(root))
        {
            childrenHeight += child.height + child.margin.height;
            childCount++;
        }

        if (spacing > 0 && childCount > 1)
        {
            childrenHeight += spacing * (childCount - 1);
        }
        return childrenHeight;
    }

    override double freeWidth(Sprite2d root, Sprite2d child)
    {
        return root.width - child.width - root.padding.width;
    }

    override double freeHeight(Sprite2d root, Sprite2d child)
    {
        return root.height - childrenHeight(root) - root.padding.height;
    }

}