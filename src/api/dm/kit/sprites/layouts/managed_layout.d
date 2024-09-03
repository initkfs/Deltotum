module api.dm.kit.sprites.layouts.managed_layout;

import api.dm.kit.sprites.layouts.layout : Layout;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.gui.controls.control : Control;
import api.math.alignment : Alignment;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class ManagedLayout : Layout
{
    //It’s easier to debug by seeing the arrangement of children
    bool isAlignBeforeResize = true;
    bool isAlignAfterResize;

    bool alignment(Sprite root, Sprite obj)
    {
        bool isAlign = true;
        if (isAlignX)
        {
            isAlign &= alignX(root, obj);
        }

        if (isAlignY)
        {
            isAlign &= alignY(root, obj);
        }

        if (obj.alignment != Alignment.none && obj.isLayoutManaged)
        {
            final switch (obj.alignment)
            {
                case Alignment.none:
                    break;
                case Alignment.x:
                    isAlign &= alignX(root, obj);
                    break;
                case Alignment.y:
                    isAlign &= alignY(root, obj);
                    break;
                case Alignment.xy:
                    isAlign &= alignXY(root, obj);
                    break;
            }
        }

        return isAlign;
    }

    bool alignXY(Sprite root, Sprite target)
    {
        const bool isX = alignX(root, target);
        const bool isY = alignY(root, target);
        return isX && isY;
    }

    bool alignX(Sprite root, Sprite target)
    {
        if (!target.isLayoutManaged)
        {
            return false;
        }
        const rootBounds = root.bounds;
        //TODO target.layoutBounds
        const targetBounds = target.bounds;

        if (rootBounds.width == 0 || targetBounds.width == 0)
        {
            return false;
        }

        const newX = rootBounds.middleX - targetBounds.halfWidth + target.margin.left - target
            .margin.right;
        if (Math.abs(target.x - newX) < sizeChangeDelta)
        {
            return false;
        }

        target.x = newX;

        return true;
    }

    bool alignY(Sprite root, Sprite target)
    {
        if (!target.isLayoutManaged)
        {
            return false;
        }
        const rootBounds = root.bounds;
        const targetBounds = target.bounds;

        if (rootBounds.height == 0 || targetBounds.height == 0)
        {
            return false;
        }

        const newY = rootBounds.middleY - targetBounds.halfHeight + target.margin.top - target
            .margin.bottom;
        if (Math.abs(target.y - newY) < sizeChangeDelta)
        {
            return false;
        }

        target.y = newY;
        return true;
    }

    bool alignChildren(Sprite root)
    {
        bool isAlign = true;
        foreach (child; root.children)
        {
            isAlign &= alignment(root, child);
        }
        return isAlign;
    }

    bool alignForLayout(Sprite root)
    {
        if (isAlignXifOneChild || isAlignYifOneChild)
        {
            import std.range.primitives : walkLength, front;

            //TODO children count cache?
            auto children = childrenForLayout(root);
            auto childCount = children.walkLength;

            if (childCount == 1)
            {
                bool isAlignX, isAlignY;
                if (isAlignXifOneChild)
                {
                    isAlignX = alignX(root, children.front);
                }

                if (isAlignYifOneChild)
                {
                    isAlignY = alignY(root, children.front);
                }

                return isAlignX || isAlignY;
            }
        }

        return alignChildren(root);
    }

    override void applyLayout(Sprite root)
    {
        if (isAlignBeforeResize)
        {
            alignForLayout(root);
        }

        if (isIncreaseRootWidth || isDecreaseRootWidth)
        {
            resizeRootWidth(root);
        }

        if (isIncreaseRootHeight || isDecreaseRootHeight)
        {
            resizeRootHeight(root);
        }

        if (isResizeChildren || root.isResizeChildren)
        {
            resizeChildren(root);
        }

        if (isAlignAfterResize)
        {
            alignForLayout(root);
        }
    }

    void resizeRootWidth(Sprite root)
    {
        double newWidth = childrenWidth(root);
        if (root.padding.width > 0)
        {
            newWidth += root.padding.width;
        }

        if (newWidth > root.width)
        {
            if (isIncreaseRootWidth)
            {
                if (newWidth >= root.minWidth && newWidth <= root.maxWidth && (
                        Math.abs(root.width - newWidth) >= sizeChangeDelta))
                {
                    root.width = newWidth;
                }
            }
        }
        else
        {
            if (isDecreaseRootWidth)
            {
                auto newDecrWidth = root.width - newWidth;
                if (newDecrWidth > 0)
                {
                    if (
                        newDecrWidth >= root.minWidth &&
                        newDecrWidth <= root.maxWidth &&
                        Math.abs(root.width - newDecrWidth) >= sizeChangeDelta)
                    {
                        root.width = newDecrWidth;
                    }
                }
            }
        }
    }

    void resizeRootHeight(Sprite root)
    {
        double newHeight = childrenHeight(root);
        if (root.padding.height > 0)
        {
            newHeight += root.padding.height;
        }

        if (newHeight > root.height)
        {
            if (isIncreaseRootHeight)
            {
                if (newHeight >= root.minHeight && newHeight <= root.maxHeight && (
                        Math.abs(root.height - newHeight) >= sizeChangeDelta))
                {
                    root.height = newHeight;
                }
            }
        }
        else
        {
            if (isDecreaseRootHeight)
            {
                auto newDecrHeight = root.height - newHeight;
                if (newDecrHeight > 0)
                {
                    if (newDecrHeight >= root.minHeight && newDecrHeight <= root.maxHeight && (
                            Math.abs(root.height - newDecrHeight) >= sizeChangeDelta))
                    {
                        root.height = newDecrHeight;
                    }
                }
            }
        }
    }

    double freeWidth(Sprite root, Sprite child)
    {
        return root.width - child.width - root.padding.width;
    }

    double freeHeight(Sprite root, Sprite child)
    {
        return root.height - child.height - root.padding.height;
    }

    //TODO the first child occupies all available space
    void resizeChildren(Sprite root)
    {
        import std.range.primitives : empty, walkLength;
        import std.algorithm.searching : count;

        auto targetChildren = childrenForLayout(root);
        if (targetChildren.empty)
        {
            return;
        }

        double reduceWidth = 0;
        if (isDecreaseChildrenWidth)
        {
            auto chWidth = childrenWidth(root);
            if (chWidth > root.width)
            {
                auto rootWidth = root.width;
                if (root.padding.width > 0 || root.padding.width < rootWidth)
                {
                    rootWidth -= root.padding.width;
                }
                auto dw = chWidth - rootWidth;
                reduceWidth = dw / targetChildren.walkLength;
            }
        }

        double reduceHeight = 0;
        if (isDecreaseChildrenHeight)
        {
            auto chHeight = childrenHeight(root);
            if (chHeight > root.height)
            {
                auto rootHeight = root.height;
                if (root.padding.height > 0 || root.padding.height < rootHeight)
                {
                    rootHeight -= root.padding.height;
                }
                auto dh = chHeight - rootHeight;
                reduceHeight = dh / targetChildren.walkLength;
            }
        }

        const hgrowChildren = targetChildren.count!(ch => ch.isHGrow);
        const vgrowChildren = targetChildren.count!(ch => ch.isVGrow);

        if (reduceWidth == 0 && reduceHeight == 0 && hgrowChildren == 0 && vgrowChildren == 0)
        {
            return;
        }

        foreach (child; targetChildren)
        {
            //TODO min, max, delta
            if (reduceWidth > 0)
            {
                child.width = reduceWidth;
            }

            if (reduceHeight > 0)
            {
                child.height = reduceHeight;
            }

            if (child.isHGrow)
            {
                const freeW = freeWidth(root, child);
                const dtWidth = Math.trunc(freeW / hgrowChildren);

                if (dtWidth > 0)
                {
                    const newWidth = child.width + dtWidth;
                    if (Math.abs(child.width - newWidth) >= sizeChangeDelta)
                    {
                        child.width = newWidth;
                    }
                }
            }

            if (child.isVGrow)
            {
                import Math = api.dm.math;

                const freeH = freeHeight(root, child);
                const dtHeight = Math.trunc(freeH / vgrowChildren);

                if (dtHeight > 0)
                {
                    const newHeight = child.height + dtHeight;
                    if (Math.abs(child.height - newHeight) >= sizeChangeDelta)
                    {
                        child.height = newHeight;
                    }
                }
            }
        }
    }

    override double childrenWidth(Sprite root)
    {
        if (root.children.length == 0)
        {
            return 0;
        }

        auto targetChildren = childrenForLayout(root);
        double childrendWidth = 0;
        foreach (child; targetChildren)
        {
            childrendWidth += child.width + child.margin.width;
        }

        return childrendWidth;
    }

    override double childrenHeight(Sprite root)
    {
        if (root.children.length == 0)
        {
            return 0;
        }

        auto targetChildren = childrenForLayout(root);
        double childrendHeight = 0;
        foreach (child; targetChildren)
        {
            childrendHeight += child.height + child.margin.height;
        }

        return childrendHeight;
    }

}
