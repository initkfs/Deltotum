module deltotum.kit.display.layouts.center_layout;

import deltotum.kit.display.display_object : DisplayObject;
import deltotum.kit.display.layouts.managed_layout : ManagedLayout;

/**
 * Authors: initkfs
 */
class CenterLayout : ManagedLayout
{
    override void applyLayout(DisplayObject root)
    {
        foreach (child; root.children)
        {
            alignXY(root, child);
        }
    }
}
