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

    this(double spacing = 10) pure
    {
        import std.exception : enforce;
        import std.conv : text;

        enforce(spacing >= 0, text("Horizontal spacing must be positive value or 0: ", spacing));
        this.spacing = spacing;

        this.layout = new HorizontalLayout(spacing);
    }

    override void requestLayout()
    {
        //obj.padding.width
        const double newWidth = childrenWidth;
        if (newWidth > width)
        {
            double maxW = maxWidth;
            if (padding.width > 0 && maxW > padding.width)
            {
                maxW -= padding.width;
            }

            if (newWidth < maxW)
            {
                width = newWidth;
            }
            else
            {
                const double decWidth = (maxW - padding.width) / children.length;
                foreach (ch; children)
                {
                    ch.width(ch.width - decWidth);
                }
            }

        }

        const double maxH = childrenHeight;
        if (maxH > height - padding.height)
        {
            import std.algorithm.comparison : min;

            height = min(maxH, maxHeight - padding.height);
        }
    }

    double childrenWidth()
    {
        import std.algorithm.iteration : sum, map;
        import std.algorithm.iteration: filter;

        const double childrenWidth = children.filter!(ch => ch.isLayoutManaged).map!(ch => ch.width).sum;
        return childrenWidth;
    }

    double childrenHeight()
    {
        if (children.length == 0)
        {
            return 0;
        }
        import std.algorithm.searching : maxElement;
        import std.algorithm.iteration: filter, map;
        import std.algorithm.comparison: max;
        import std.range.primitives: walkLength;

        auto childrenRange = children.filter!(ch => ch.isLayoutManaged);
        if(childrenRange.walkLength == 0){
            return 0;
        }
        
        const double childrenMaxHeight = childrenRange.maxElement!"a.height".height;
        return childrenMaxHeight;
    }

}
