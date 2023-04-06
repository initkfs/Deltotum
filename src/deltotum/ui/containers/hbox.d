module deltotum.ui.containers.hbox;

import deltotum.ui.containers.container : Container;
import deltotum.toolkit.display.layouts.horizontal_layout : HorizontalLayout;
import deltotum.toolkit.display.display_object : DisplayObject;

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

        super.requestLayout;
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
        import std.algorithm.iteration: filter;

        const double childrenMaxHeight = children.filter!(ch => ch.isLayoutManaged).maxElement!("a.height").height;
        return childrenMaxHeight;
    }
}
