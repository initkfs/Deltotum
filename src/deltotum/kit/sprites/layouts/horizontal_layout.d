module deltotum.kit.sprites.layouts.horizontal_layout;

import deltotum.kit.sprites.sprite : Sprite;
import deltotum.kit.sprites.layouts.managed_layout : ManagedLayout;
import deltotum.kit.sprites.alignment : Alignment;

/**
 * Authors: initkfs
 */
class HorizontalLayout : ManagedLayout
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
                child.x = nextX + child.margin.left;
                nextX = child.x + childBounds.width + child.margin.right + spacing;
            }
            else
            {
                child.x = nextX - child.margin.right - childBounds.width;
                nextX = child.x - child.margin.left - spacing;
            }

            if (isAlignY || child.alignment == Alignment.y)
            {
                alignY(root, child);
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
            if (child.height > childrenHeight)
            {
                childrenHeight = child.height;
            }
        }

        return childrenHeight;
    }
}
