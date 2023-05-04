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
        return isX || isY;
    }

    bool alignX(Sprite root, Sprite target)
    {
        if(!target.isLayoutManaged){
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
        if(!target.isLayoutManaged){
            return false;
        }
        const rootBounds = root.bounds;
        const targetBounds = target.bounds;

        if (rootBounds.height == 0 || targetBounds.height == 0)
        {
            return false;
        }

        const newY = rootBounds.middleY - targetBounds.halfHeight ;
        target.y = newY;
        return true;
    }

    override void applyLayout(Sprite root)
    {
        foreach (child; root.children)
        {
            alignment(root, child);
        }
    }
}
