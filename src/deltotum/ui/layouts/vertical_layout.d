module deltotum.ui.layouts.vertical_layout;

import deltotum.display.display_object : DisplayObject;
import deltotum.ui.layouts.managed_layout : ManagedLayout;
import deltotum.math.alignment : Alignment;

/**
 * Authors: initkfs
 */
class VerticalLayout : ManagedLayout
{
    @property double spacing = 0;

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
