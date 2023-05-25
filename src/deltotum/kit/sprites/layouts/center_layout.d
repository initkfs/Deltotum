module deltotum.kit.sprites.layouts.center_layout;

import deltotum.kit.sprites.sprite : Sprite;
import deltotum.kit.sprites.layouts.managed_layout : ManagedLayout;

/**
 * Authors: initkfs
 */
class CenterLayout : ManagedLayout
{
    override void arrangeChildren(Sprite root)
    {
        foreach (child; root.children)
        {
            alignXY(root, child);
        }
    }

    override double childrenWidth(Sprite root)
    {
        double maxWidth = 0;
        foreach (child; childrenForLayout(root))
        {
            const childW = child.width + child.margin.width;
            if (childW > maxWidth)
            {
                maxWidth = childW;
            }
        }

        return maxWidth;
    }

    override double childrenHeight(Sprite root)
    {
        double maxHeight = 0;
        foreach (child; childrenForLayout(root))
        {
            const childH = child.height + child.margin.height;
            if (childH > maxHeight)
            {
                maxHeight = childH;
            }
        }

        return maxHeight;
    }
}
