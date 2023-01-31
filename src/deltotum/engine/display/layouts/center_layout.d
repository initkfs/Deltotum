module deltotum.engine.display.layouts.center_layout;

import deltotum.engine.display.display_object : DisplayObject;
import deltotum.engine.display.layouts.managed_layout : ManagedLayout;

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
