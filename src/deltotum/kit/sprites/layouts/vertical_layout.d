module deltotum.kit.sprites.layouts.vertical_layout;

import deltotum.kit.sprites.sprite : Sprite;
import deltotum.kit.sprites.layouts.managed_layout : ManagedLayout;
import deltotum.kit.sprites.alignment : Alignment;

/**
 * Authors: initkfs
 */
class VerticalLayout : ManagedLayout
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

    //TODO REMOVE duplication.
    override void layoutResizeChildren(Sprite root)
    {
        import std.range.primitives : empty, walkLength;
        import std.algorithm.searching : count;

        auto targetChildren = childrenForLayout(root);
        if (targetChildren.empty)
        {
            return;
        }

        const hgrowChildren = targetChildren.count!(ch => ch.isHGrow);
        const vgrowChildren = targetChildren.count!(ch => ch.isVGrow);

        if (hgrowChildren == 0 && vgrowChildren == 0)
        {
            return;
        }

        auto freeW = root.width - root.padding.width;
        if (freeW < 0)
        {
            freeW = 0;
        }
        const freeH = freeHeight(root);

        const dtWidth = freeW;
        const dtHeight = freeH / vgrowChildren;

        foreach (child; targetChildren)
        {
            if (child.isHGrow && dtWidth > 0)
            {
                child.isProcessLayout = true;
                child.width = dtWidth;
            }

            if (child.isVGrow)
            {
                child.isProcessLayout = true;
                child.height = child.height + dtHeight;
            }
        }
    }

}
