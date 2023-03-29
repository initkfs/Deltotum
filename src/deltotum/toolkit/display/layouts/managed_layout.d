module deltotum.toolkit.display.layouts.managed_layout;

import deltotum.toolkit.display.layouts.layout : Layout;
import deltotum.toolkit.display.display_object : DisplayObject;
import deltotum.ui.controls.control : Control;
import deltotum.toolkit.display.alignment : Alignment;

/**
 * Authors: initkfs
 */
class ManagedLayout : Layout
{

    bool alignment(DisplayObject root, DisplayObject obj)
    {
        if (obj.alignment == Alignment.none)
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

    bool alignXY(DisplayObject root, DisplayObject target)
    {
        const bool isX = alignX(root, target);
        const bool isY = alignY(root, target);
        return isX || isY;
    }

    bool alignX(DisplayObject root, DisplayObject target)
    {
        const rootBounds = root.bounds;
        const targetBounds = target.bounds;

        if (rootBounds.width == 0 || targetBounds.width == 0)
        {
            return false;
        }

        const newX = rootBounds.middleX - targetBounds.halfWidth + root.padding.left;
        target.x = newX;
        return true;
    }

    bool alignY(DisplayObject root, DisplayObject target)
    {
        const rootBounds = root.bounds;
        const targetBounds = target.bounds;

        if (rootBounds.height == 0 || targetBounds.height == 0)
        {
            return false;
        }

        const newY = rootBounds.middleY - targetBounds.halfHeight + root.padding.top;
        target.y = newY;
        return true;
    }

    override void layout(DisplayObject root)
    {
        foreach (child; root.children)
        {
            alignment(root, child);
        }
    }
}
