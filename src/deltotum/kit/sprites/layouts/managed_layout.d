module deltotum.kit.sprites.layouts.managed_layout;

import deltotum.kit.sprites.layouts.layout : Layout;
import deltotum.kit.sprites.sprite : Sprite;
import deltotum.gui.controls.control : Control;
import deltotum.kit.sprites.alignment : Alignment;

/**
 * Authors: initkfs
 */
class ManagedLayout : Layout
{

    bool alignment(Sprite root, Sprite obj)
    {
        if (isAlignX)
        {
            return alignX(root, obj);
        }

        if (isAlignY)
        {
            return alignY(root, obj);
        }

        if (obj.alignment == Alignment.none || !obj.isLayoutManaged)
        {
            return false;
        }

        final switch (obj.alignment)
        {
        case Alignment.none:
            return false;
        case Alignment.x:
            return alignX(root, obj);
        case Alignment.y:
            return alignY(root, obj);
        case Alignment.xy:
            return alignXY(root, obj);
        }
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
        const targetBounds = target.bounds;

        if (rootBounds.width == 0 || targetBounds.width == 0)
        {
            return false;
        }

        const newX = rootBounds.middleX - targetBounds.halfWidth;
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

    override void applyLayout(Sprite root)
    {
        if (isResizeParent)
        {
            const bool rootOldLayoutStatus = root.isProcessLayout;
            root.isProcessLayout = true;
            layoutResize(root);
            root.isProcessLayout = rootOldLayoutStatus;
        }

        if (isResizeChildren)
        {
            const bool rootOldProcessChildLayout = root.isProcessChildLayout;
            root.isProcessChildLayout = true;
            layoutResizeChildren(root);
            root.isProcessChildLayout = rootOldProcessChildLayout;
        }

        arrangeChildren(root);
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
            if (newWidth < root.maxWidth)
            {
                root.width = newWidth;
            }
        }

        double newHeight = childrenHeight(root);
        if (root.padding.height > 0)
        {
            newHeight += root.padding.height;
        }

        if (newHeight > root.height)
        {
            if (newHeight < root.maxHeight)
            {
                root.height = newHeight;
            }
        }
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

        const freeWidth = root.width - childrenWidth(root) - root.padding.width;
        const freeHeight = root.height - childrenHeight(root) - root.padding.height;

        const dtWidth = freeWidth / hgrowChildren;
        const dtHeight = freeHeight / vgrowChildren;

        foreach (child; targetChildren)
        {
            if (child.isHGrow)
            {
                child.width = child.width + dtWidth;
            }

            if (child.isVGrow)
            {
                child.height = child.height + dtHeight;
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
