module deltotum.toolkit.display.layouts.horizontal_layout;

import deltotum.toolkit.display.display_object : DisplayObject;
import deltotum.toolkit.display.layouts.managed_layout : ManagedLayout;
import deltotum.toolkit.display.alignment : Alignment;

/**
 * Authors: initkfs
 */
class HorizontalLayout : ManagedLayout
{
    double spacing = 0;

    this(double spacing = 0)
    {
        this.spacing = spacing;
    }

    override void layout(DisplayObject root)
    {
        auto bounds = root.bounds;
        double nextX = bounds.x;
        foreach (child; root.children)
        {
            if (!child.isLayoutManaged)
            {
                continue;
            }
            auto childBounds = child.bounds;
            child.x = nextX;
            nextX = child.x + childBounds.width + spacing;

            if (child.alignment == Alignment.y)
            {
                alignY(root, child);
            }
        }
    }
}
