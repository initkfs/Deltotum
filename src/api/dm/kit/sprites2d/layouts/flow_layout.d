module api.dm.kit.sprites2d.layouts.flow_layout;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.layouts.managed_layout : ManagedLayout;
import api.math.pos2.alignment : Alignment;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class FlowLayout : ManagedLayout
{
    double vgap = 0;
    double hgap = 0;

    double flowWidth = 0;
    bool isUseFlowWidth;

    this(double hgap = 0, double vgap = 0, double flowWidth = 0) pure
    {
        this.hgap = hgap;
        this.vgap = vgap;
        this.flowWidth = flowWidth;
    }

    //TODO check paddng, margins, etc
    override bool alignChildren(Sprite2d root)
    {
        const rootBounds = root.boundsRect;

        double nextX = 0;
        double nextY = 0;

        if (isFillStartToEnd)
        {
            nextX = rootBounds.x + root.padding.left;
            nextY = rootBounds.y + root.padding.top;
        }
        else
        {
            nextX = isUseFlowWidth ? rootBounds.x + flowWidth : rootBounds.right - root.padding.right;
            nextY = rootBounds.bottom - root.padding.bottom;
        }

        foreach (child; root.children)
        {
            if (!child.isLayoutManaged)
            {
                continue;
            }

            const childBounds = child.boundsRect;

            const childHeight = childBounds.height + child.margin.height;

            if (isFillStartToEnd)
            {
                const rootRightEndX = isUseFlowWidth ? rootBounds.x + flowWidth : rootBounds.right - root.padding.right;
                const newChildX = nextX + child.margin.left;
                const newChildEndX = newChildX + childBounds.width + child.margin.right;
                //TODO > not =
                if (newChildEndX >= rootRightEndX)
                {
                    nextX = rootBounds.x + root.padding.left;
                    //TODO line height
                    nextY += vgap + childHeight;
                }
                else
                {
                    nextX = newChildX;
                }

                if (Math.abs(nextX - child.x) >= sizeChangeDelta)
                {
                    child.x = nextX;
                }

                if (Math.abs(nextY - child.y) >= sizeChangeDelta)
                {
                    child.y = nextY;
                }

                nextX += child.boundsRect.width + hgap + child.margin.right;
            }
            else
            {
                const rootLeftX = rootBounds.x + root.padding.left;
                const newChildX = nextX - childBounds.width - child.margin.right;
                if (newChildX < rootLeftX)
                {
                    const rootEndX = isUseFlowWidth ? root.boundsRect.x + flowWidth : root.boundsRect.right - root.padding.right;
                    nextX = rootEndX - childBounds.width;
                    //TODO line height
                    nextY -= vgap + childHeight;
                }
                else
                {
                    nextX = newChildX;
                }

                if (Math.abs(child.x - nextX) >= sizeChangeDelta)
                {
                    child.x = nextX;
                }

                const newChildY = nextY - childBounds.height - child.padding.bottom;
                if (Math.abs(child.y - newChildY) >= sizeChangeDelta)
                {
                    child.y = newChildY;
                }

                nextX = child.boundsRect.x - hgap - child.margin.left;
            }
        }
        return true;
    }

    override double calcChildrenWidth(Sprite2d root)
    {
        double calcChildrenWidth = 0;
        size_t childCount;
        foreach (child; childrenForLayout(root))
        {
            calcChildrenWidth += child.width + child.margin.width;
            childCount++;
        }

        if (hgap > 0 && childCount > 1)
        {
            calcChildrenWidth += hgap * (childCount - 1);
        }
        return calcChildrenWidth;
    }

    override double calcChildrenHeight(Sprite2d root)
    {
        double calcChildrenHeight = 0;
        size_t childCount;
        foreach (child; childrenForLayout(root))
        {
            calcChildrenHeight += child.height + child.margin.height;
            childCount++;
        }

        if (vgap > 0 && childCount > 1)
        {
            calcChildrenHeight += vgap * (childCount - 1);
        }
        return calcChildrenHeight;
    }
}
