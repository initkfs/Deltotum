module deltotum.kit.sprites.layouts.center_layout;

import deltotum.kit.sprites.sprite : Sprite;
import deltotum.kit.sprites.layouts.managed_layout : ManagedLayout;

/**
 * Authors: initkfs
 */
class CenterLayout : ManagedLayout
{
    override void applyLayout(Sprite root)
    {
        foreach (child; root.children)
        {
            alignXY(root, child);
        }
    }
}
