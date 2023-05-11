module deltotum.gui.containers.vbox;

import deltotum.gui.containers.container : Container;
import deltotum.kit.sprites.layouts.vertical_layout : VerticalLayout;

/**
 * Authors: initkfs
 */
class VBox : Container
{
    double spacing = 0;

    this(double spacing = 0) pure
    {
        import std.exception : enforce;
        import std.conv : text;

        enforce(spacing >= 0, text("Vertical spacing must be positive value: ", spacing));
        this.spacing = spacing;

        this.layout = new VerticalLayout(spacing);
    }

    double childrenWidth()
    {
        if (children.length == 0)
        {
            return 0;
        }
        import std.algorithm.searching : maxElement;
        import std.algorithm.iteration : filter;

        const double childrenMaxWidth = children.filter!(ch => ch.isLayoutManaged)
            .maxElement!("a.width")
            .width;
        return childrenMaxWidth;
    }

    double childrenHeight()
    {
        if (children.length == 0)
        {
            return 0;
        }

        import std.algorithm.iteration : sum, map;
        import std.algorithm.iteration : filter;

        const double childrenHeight = children.filter!(ch => ch.isLayoutManaged)
            .map!(ch => ch.height)
            .sum;
        return childrenHeight;
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
                const double decWidth = maxW - padding.width;
                foreach (ch; children)
                {
                    ch.width = decWidth;
                }
            }

        }

        const double newHeight = childrenHeight;
        if (newHeight > height)
        {
            double maxH = maxHeight;
            if (padding.height > 0 && maxH > padding.height)
            {
                maxH -= padding.width;
            }

            if (newHeight < maxH)
            {
                height = newHeight;
            }
            else
            {
                const double decHeight = (maxH - padding.height) / children.length;
                foreach (ch; children)
                {
                    ch.height = decHeight;
                }
            }

        }
    }
}
