module deltotum.kit.sprites.layouts.horizontal_layout;

import deltotum.kit.sprites.sprite : Sprite;
import deltotum.kit.sprites.layouts.managed_layout : ManagedLayout;
import deltotum.kit.sprites.alignment : Alignment;

/**
 * Authors: initkfs
 */
class HorizontalLayout : ManagedLayout
{
    double spacing = 0;

    this(double spacing = 0) pure
    {
        this.spacing = spacing;
    }

    override void applyLayout(Sprite root)
    {
        auto bounds = root.bounds;
        double nextX = bounds.x + root.padding.left;
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
