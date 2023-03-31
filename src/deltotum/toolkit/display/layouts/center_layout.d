module deltotum.toolkit.display.layouts.center_layout;

import deltotum.toolkit.display.display_object : DisplayObject;
import deltotum.toolkit.display.layouts.managed_layout : ManagedLayout;

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
