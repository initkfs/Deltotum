module deltotum.gui.containers.hbox;

import deltotum.gui.containers.container : Container;
import deltotum.kit.sprites.layouts.horizontal_layout : HorizontalLayout;
import deltotum.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
class HBox : Container
{
    double spacing = 0;

    this(double spacing = 5) pure
    {
        import std.exception : enforce;
        import std.conv : text;

        enforce(spacing >= 0, text("Horizontal spacing must be positive value or 0: ", spacing));
        this.spacing = spacing;

        auto hlayout = new HorizontalLayout(spacing);
        hlayout.isAlignY = true;
        this.layout = hlayout;
    }

    override double childrenWidth()
    {
        double childrenWidth = 0;
        size_t childCount;
        foreach (child; childrenForLayout)
        {
            childrenWidth += child.width + child.margin.width;
            childCount++;
        }

        if (spacing > 0 && childCount > 1)
        {
            childrenWidth += spacing * (childCount - 1);
        }
        return childrenWidth;
    }

    override double childrenHeight()
    {
        double childrenHeight = 0;
        foreach (child; childrenForLayout)
        {
            if (child.height > childrenHeight)
            {
                childrenHeight = child.height;
            }
        }

        return childrenHeight;
    }
}
