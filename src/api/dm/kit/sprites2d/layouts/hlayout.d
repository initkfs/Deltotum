module api.dm.kit.sprites2d.layouts.hlayout;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.layouts.spaceable_layout : SpaceableLayout;
import api.math.pos2.alignment : Alignment;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class HLayout : SpaceableLayout
{
    bool isInvertY;

    this(float spacing = SpaceableLayout.DefaultSpacing) pure
    {
        super(spacing);
    }

    override bool alignChildren(Sprite2d root)
    {
        auto bounds = root.boundsRect;
        float nextX = 0;
        if (isFillStartToEnd)
        {
            nextX = bounds.x + root.padding.left;
        }
        else
        {
            nextX = bounds.right - root.padding.right;
        }

        foreach (child; root.children)
        {
            if (!child.isLayoutManaged || !child.isLayoutMovable)
            {
                continue;
            }
            auto childBounds = child.boundsRect;

            if (isAlignX || child.alignment == Alignment.x)
            {
                alignX(root, child);
            }
            else
            {
                if (isFillStartToEnd)
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
            }

            if (isAlignY || child.alignment == Alignment.y)
            {
                alignY(root, child);
            }
            else
            {
                const newChildY = (isInvertY || child.isLayoutInvertY) ? (
                    root.boundsRect.bottom - root.padding.bottom - child.margin.bottom - child
                        .height) : (root.y + root.padding.top + child.margin.top);
                if (Math.abs(child.y - newChildY) >= sizeChangeDelta)
                {
                    child.y = newChildY;
                }
            }
        }
        return true;
    }

    override float calcChildrenWidth(Sprite2d root)
    {
        if (childrenWidthProvider)
        {
            return childrenWidthProvider(root);
        }

        float calcChildrenWidth = 0;
        size_t childCount;
        foreach (child; childrenForLayout(root))
        {
            calcChildrenWidth += child.width + child.margin.width;
            childCount++;
        }

        if (childCount > 1)
        {
            calcChildrenWidth += spacing * (childCount - 1);
        }
        return calcChildrenWidth;
    }

    override float calcChildrenHeight(Sprite2d root)
    {
        float calcChildrenHeight = 0;
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

    override float freeWidth(Sprite2d root, Sprite2d child)
    {
        return root.width - calcChildrenWidth(root) - root.padding.width;
    }

    override float freeHeight(Sprite2d root, Sprite2d child)
    {
        return root.height - child.height - root.padding.height;
    }
}
