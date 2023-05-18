module deltotum.kit.sprites.layouts.vertical_layout;

import deltotum.kit.sprites.sprite : Sprite;
import deltotum.kit.sprites.layouts.managed_layout : ManagedLayout;
import deltotum.kit.sprites.alignment : Alignment;

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

    override void applyLayout(Sprite root)
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

            if (isAlignX || child.alignment == Alignment.x)
            {
                alignX(root, child);
            }
        }
    }
}
