module deltotum.toolkit.display.layouts.vertical_layout;

import deltotum.toolkit.display.display_object : DisplayObject;
import deltotum.toolkit.display.layouts.managed_layout : ManagedLayout;
import deltotum.toolkit.display.alignment : Alignment;

/**
 * Authors: initkfs
 */
class VerticalLayout : ManagedLayout
{
    double spacing = 0;

    this(double spacing = 0)
    {
        this.spacing = spacing;
    }

    override void layout(DisplayObject root)
    {
        auto bounds = root.bounds;
        double nextY = bounds.y;
        foreach (child; root.children)
        {
            if (!child.isLayoutManaged)
            {
                continue;
            }
            auto childBounds = child.bounds;
            child.y = nextY;
            nextY = child.y + childBounds.height + spacing;

            if (child.alignment == Alignment.x)
            {
                alignX(root, child);
            }
        }
    }
}
