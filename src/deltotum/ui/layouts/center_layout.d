module deltotum.ui.layouts.center_layout;

import deltotum.display.display_object : DisplayObject;
import deltotum.ui.layouts.managed_layout : ManagedLayout;

/**
 * Authors: initkfs
 */
class CenterLayout : ManagedLayout
{
    override void layout(DisplayObject root)
    {
        foreach (child; root.children)
        {
            alignXY(root, child);
        }
    }
}
