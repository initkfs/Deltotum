module dm.kit.sprites.layouts.managed_layout;

import dm.kit.sprites.layouts.layout : Layout;
import dm.kit.sprites.sprite : Sprite;
import dm.gui.controls.control : Control;
import dm.math.alignment : Alignment;

import Math = dm.math;

/**
 * Authors: initkfs
 */
class ManagedLayout : Layout
{
    bool isArrangeBeforeResize;
    bool isArrangeAfterResize = true;

    bool alignment(Sprite root, Sprite obj)
    {
        //TODO return bool?
        if (isAlignX)
        {
            alignX(root, obj);
        }

        if (isAlignY)
        {
            alignY(root, obj);
        }

        if (obj.alignment != Alignment.none && obj.isLayoutManaged)
        {
            final switch (obj.alignment)
            {
                case Alignment.none:
                    break;
                case Alignment.x:
                    alignX(root, obj);
                    break;
                case Alignment.y:
                    alignY(root, obj);
                    break;
                case Alignment.xy:
                    alignXY(root, obj);
                    break;
            }
        }

        //TODO all bools?
        return true;
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

        const newX = rootBounds.middleX - targetBounds.halfWidth;
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

        const newY = rootBounds.middleY - targetBounds.halfHeight;
        if (Math.abs(target.y - newY) < sizeChangeDelta)
        {
            return false;
        }

        target.y = newY;
        return true;
    }

    void arrangeChildren(Sprite root)
    {
        foreach (child; root.children)
        {
            alignment(root, child);
        }
    }

    bool arrangeForLayout(Sprite root)
    {
        bool isAlignX, isAlignY;
        if (isAlignXifOneChild || isAlignYifOneChild)
        {
            import std.range.primitives : walkLength, front;

            auto children = childrenForLayout(root);
            auto childCount = children.walkLength;

            if (childCount == 1)
            {
                if (isAlignXifOneChild)
                {
                    alignX(root, children.front);
                    isAlignX = true;
                }

                if (isAlignYifOneChild)
                {
                    alignY(root, children.front);
                    isAlignY = true;
                }
            }
        }

        if (isAlignX || isAlignY)
        {
            return true;
        }

        arrangeChildren(root);
        return true;
    }

    override void applyLayout(Sprite root)
    {
        if (isArrangeBeforeResize)
        {
            arrangeForLayout(root);
        }

        if (isResizeParent)
        {
            layoutResize(root);
        }

        if (isResizeChildren || root.isResizeChildren)
        {
            layoutResizeChildren(root);
        }

        if (isArrangeAfterResize)
        {
            arrangeForLayout(root);
        }
    }

    void layoutResize(Sprite root)
    {
        double newWidth = childrenWidth(root);
        if (root.padding.width > 0)
        {
            newWidth += root.padding.width;
        }

        if (newWidth > root.width)
        {
            if (newWidth >= root.minWidth && newWidth <= root.maxWidth && (
                    Math.abs(root.width - newWidth) >= sizeChangeDelta))
            {
                root.width = newWidth;
            }

        }

        if (isParentWidthReduce)
        {
            auto newDecWidth = root.width - newWidth;
            if (newDecWidth > 0)
            {
                if (
                    newDecWidth >= root.minWidth &&
                    newDecWidth <= root.maxWidth &&
                    Math.abs(root.width - newDecWidth) >= sizeChangeDelta)
                {
                    root.width = newDecWidth;
                }
            }
        }

        double newHeight = childrenHeight(root);
        if (root.padding.height > 0)
        {
            newHeight += root.padding.height;
        }

        if (newHeight > root.height)
        {
            if (newHeight >= root.minHeight && newHeight <= root.maxHeight && (
                    Math.abs(root.height - newHeight) >= sizeChangeDelta))
            {
                root.height = newHeight;
            }
        }

        if (isParentHeightReduce)
        {
            auto newDecHeight = root.height - newHeight;
            if (newDecHeight > 0)
            {
                if (newDecHeight >= root.minHeight && newDecHeight <= root.maxHeight && (Math.abs(root.height - newDecHeight) >= sizeChangeDelta))
                {
                    root.height = newDecHeight;
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
    void layoutResizeChildren(Sprite root)
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

        foreach (child; targetChildren)
        {
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
                import Math = dm.math;

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
