module deltotum.kit.sprites.layouts.managed_layout;

import deltotum.kit.sprites.layouts.layout : Layout;
import deltotum.kit.sprites.sprite : Sprite;
import deltotum.gui.controls.control : Control;
import deltotum.math.geom.alignment : Alignment;

/**
 * Authors: initkfs
 */
class ManagedLayout : Layout
{
    bool isArrangeBeforeResize;
    bool isArragneAfterResize = true;

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
        if (target.x == newX)
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
        if (target.y == newY)
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

    override void applyLayout(Sprite root)
    {
        if (isArrangeBeforeResize)
        {
            arrangeChildren(root);
        }

        if (isResizeParent)
        {
            layoutResize(root);
        }

        if (isResizeChildren || root.isResizeChildren)
        {
            layoutResizeChildren(root);
        }

        if (isArragneAfterResize)
        {
            arrangeChildren(root);
        }
    }

    void layoutResize(Sprite root)
    {
        double newWidth = childrenWidth(root);
        if (root.padding.width > 0)
        {
            newWidth += root.padding.width;
        }

        if (newWidth > root.width && newWidth <= root.maxWidth)
        {
            root.width = newWidth;
        }

        double newHeight = childrenHeight(root);
        if (root.padding.height > 0)
        {
            newHeight += root.padding.height;
        }

        if (newHeight > root.height)
        {
            if (newHeight <= root.maxHeight)
            {
                root.height = newHeight;
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
                import Math = deltotum.math;

                if(child.id == "tab_pane_header_separator"){
                    import std;
                    auto a = 4;
                }

                const freeW = freeWidth(root, child);
                const dtWidth = Math.trunc(freeW / hgrowChildren);

                if (dtWidth > 0)
                {

                    enum wDelta = 1.0;
                    const newWidth = child.width + dtWidth;
                    if (Math.abs(child.width - newWidth) > wDelta)
                    {
                        child.width = newWidth;
                    }
                }
            }

            if (child.isVGrow)
            {
                import Math = deltotum.math;

                const freeH = freeHeight(root, child);
                const dtHeight = Math.trunc(freeH / vgrowChildren);

                if (dtHeight > 0)
                {
                    import Math = deltotum.math;

                    enum hDelta = 1.0;

                    const newHeight = child.height + dtHeight;
                    if (Math.abs(child.height - newHeight) > hDelta)
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
