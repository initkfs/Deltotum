module api.dm.kit.sprites2d.layouts.vlayout;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.layouts.spaceable_layout : SpaceableLayout;
import api.math.pos2.alignment : Alignment;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class VLayout : SpaceableLayout
{
    bool isInvertX;

    this(float spacing = SpaceableLayout.DefaultSpacing) pure
    {
        super(spacing);
    }

    override bool alignChildren(Sprite2d root)
    {
        auto bounds = root.boundsRect;
        float nextY = 0;
        if (isFillStartToEnd)
        {
            nextY = bounds.y + root.padding.top;
        }
        else
        {
            nextY = bounds.bottom - root.padding.bottom;
        }

        foreach (child; root.children)
        {
            if (!child.isLayoutManaged || !child.isLayoutMovable)
            {
                continue;
            }

            auto childBounds = child.boundsRect;

            if (isAlignY || child.alignment == Alignment.y)
            {
                alignY(root, child);
            }
            else
            {
                if (isFillStartToEnd)
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
            }

            if (isAlignX || child.alignment == Alignment.x)
            {
                alignX(root, child);
            }
            else
            {
                const newChildX = (isInvertX || child.isLayoutInvertX) ? (
                    root.boundsRect.right - root.padding.right - child.margin.right - child.width) : (
                    root.x + root.padding.left + child.margin.left);
                if (Math.abs(newChildX - child.x) > sizeChangeDelta)
                {
                    child.x = newChildX;
                }
            }
        }
        return true;
    }

    override float calcChildrenWidth(Sprite2d root)
    {
        float calcChildrenWidth = 0;
        foreach (child; childrenForLayout(root))
        {
            const chWidth = child.width + child.margin.width;
            if (chWidth > calcChildrenWidth)
            {
                calcChildrenWidth = chWidth;
            }
        }

        return calcChildrenWidth;
    }

    override float calcChildrenHeight(Sprite2d root)
    {
        float calcChildrenHeight = 0;
        size_t childCount;
        foreach (child; childrenForLayout(root))
        {
            calcChildrenHeight += child.height + child.margin.height;
            childCount++;
        }

        if (childCount > 1)
        {
            calcChildrenHeight += spacing * (childCount - 1);
        }

        return calcChildrenHeight;
    }

    override float freeWidth(Sprite2d root, Sprite2d child)
    {
        return root.width - child.width - root.padding.width;
    }

    override float freeHeight(Sprite2d root, Sprite2d child)
    {
        return root.height - calcChildrenHeight(root) - root.padding.height;
    }

}
