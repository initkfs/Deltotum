module deltotum.gui.containers.vbox;

import deltotum.gui.containers.container : Container;
import deltotum.kit.sprites.layouts.vertical_layout : VerticalLayout;

/**
 * Authors: initkfs
 */
class VBox : Container
{
    double spacing = 0;

    this(double spacing = 5) pure
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
        double childrenWidth = 0;
        foreach (child; childrenForLayout)
        {
            if (child.width > childrenWidth)
            {
                childrenWidth = child.width;
            }
        }

        return childrenWidth;
    }

    override double childrenHeight()
    {
        double childrenHeight = 0;
        size_t childCount;
        foreach (child; childrenForLayout)
        {
            childrenHeight += child.height + child.margin.height;
            childCount++;
        }

        if (spacing > 0 && childCount > 1)
        {
            childrenHeight += spacing * (childCount - 1);
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
