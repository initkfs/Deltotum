module deltotum.engine.display.layouts.horizontal_layout;

import deltotum.engine.display.display_object : DisplayObject;
import deltotum.engine.display.layouts.managed_layout : ManagedLayout;
import deltotum.engine.display.alignment : Alignment;

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
