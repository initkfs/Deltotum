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

        auto vlayout = new VerticalLayout(spacing);
        vlayout.isAlignX = true;
        this.layout = vlayout;
    }

    override double childrenWidth()
    {
        if (children.length == 0)
        {
            return 0;
        }
        import std.algorithm.searching : maxElement;
        import std.range.primitives : empty;

        auto childrenForCalc = childrenWithGeometry;
        if (childrenForCalc.empty)
        {
            return 0;
        }

        const double childrenMaxWidth = childrenForCalc.maxElement!("a.width").width;
        return childrenMaxWidth;
    }

    override double childrenHeight()
    {
        if (children.length == 0)
        {
            return 0;
        }

        import std.range.primitives : walkLength;
        import std.algorithm.iteration : sum, map;

        auto targetChildren = childrenWithGeometry;
        const childrenCount = targetChildren.walkLength;
        if (childrenCount == 0)
        {
            return 0;
        }

        double childrenHeight = targetChildren
            .map!(ch => ch.height)
            .sum;
        if (spacing > 0)
        {
            childrenHeight += spacing * (childrenCount - 1);
        }
        return childrenHeight;
    }

    void isAlignX(bool isAlign)
    {
        layout.isAlignX = isAlign;
    }

    bool isAlignX()
    {
        return layout.isAlignX;
    }
}

unittest
{
    import deltotum.kit.sprites.sprite : Sprite;
    import deltotum.math.geometry.insets : Insets;

    auto sp1 = new Sprite;
    sp1.width = 100;
    sp1.height = 200;

    auto container1 = new VBox;
    container1.add(sp1);
    container1.update(0);

    assert(container1.width == sp1.width);
    assert(container1.height == sp1.height);
}
