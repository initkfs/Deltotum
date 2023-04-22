module deltotum.kit.display.layouts.vertical_layout;

import deltotum.kit.display.display_object : DisplayObject;
import deltotum.kit.display.layouts.managed_layout : ManagedLayout;
import deltotum.kit.display.alignment : Alignment;

/**
 * Authors: initkfs
 */
class VerticalLayout : ManagedLayout
{
    double spacing = 0;

    this(double spacing = 0) pure
    {
        this.spacing = spacing;
    }

    override void applyLayout(DisplayObject root)
    {
        auto bounds = root.bounds;
        double nextY = bounds.y + root.padding.top;
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
