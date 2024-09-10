module api.dm.kit.sprites.layouts.center_layout;

import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.sprites.layouts.managed_layout : ManagedLayout;

/**
 * Authors: initkfs
 */
class CenterLayout : ManagedLayout
{
    override bool alignChildren(Sprite root)
    {
        bool isAlign;
        foreach (child; root.children)
        {
            isAlign |= alignXY(root, child);
        }
        return isAlign;
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
