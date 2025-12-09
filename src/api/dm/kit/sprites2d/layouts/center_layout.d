module api.dm.kit.sprites2d.layouts.center_layout;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.layouts.managed_layout : ManagedLayout;

/**
 * Authors: initkfs
 */
class CenterLayout : ManagedLayout
{
    override bool alignChildren(Sprite2d root)
    {
        bool isAlign;
        foreach (child; childrenForAlign(root))
        {
            isAlign |= alignXY(root, child);
        }
        return isAlign;
    }

    override float calcChildrenWidth(Sprite2d root)
    {
        float maxWidth = 0;
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

    override float calcChildrenHeight(Sprite2d root)
    {
        float maxHeight = 0;
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
