module dm.kit.sprites.layouts.vlayout;

import dm.kit.sprites.sprite : Sprite;
import dm.kit.sprites.layouts.managed_layout : ManagedLayout;
import dm.math.geom.alignment : Alignment;

/**
 * Authors: initkfs
 */
class VLayout : ManagedLayout
{
    double spacing = 0;

    this(double spacing = 0) pure
    {
        this.spacing = spacing;
    }

    override void arrangeChildren(Sprite root)
    {
        auto bounds = root.bounds;
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

            auto childBounds = child.bounds;

            if (isFillFromStartToEnd)
            {
                child.y = nextY + child.margin.top;
                nextY = child.y + childBounds.height + child.margin.bottom + spacing;
            }
            else
            {
                child.y = nextY - child.margin.bottom - childBounds.height;
                nextY = child.y + child.margin.top - spacing;
            }

            if (isAlignX || child.alignment == Alignment.x)
            {
                alignX(root, child);
            }
            else
            {
                child.x = root.x + root.padding.left + child.margin.left;
            }
        }
    }

    override double childrenWidth(Sprite root)
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

    override double childrenHeight(Sprite root)
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

    override double freeWidth(Sprite root, Sprite child)
    {
        return root.width - child.width - root.padding.width;
    }

    override double freeHeight(Sprite root, Sprite child)
    {
        return root.height - childrenHeight(root) - root.padding.height;
    }



}
