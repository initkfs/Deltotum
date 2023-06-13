module deltotum.gui.containers.vbox;

import deltotum.gui.containers.container : Container;
import deltotum.kit.sprites.layouts.vertical_layout : VerticalLayout;

/**
 * Authors: initkfs
 */
class VBox : Container
{
    private
    {
        double _spacing = 0;
    }

    this(double spacing = 5) pure
    {
        import std.exception : enforce;
        import std.conv : text;

        enforce(spacing >= 0, text("Vertical spacing must be positive value: ", spacing));
        this._spacing = spacing;

        auto vlayout = new VerticalLayout(_spacing);
        vlayout.isAlignX = true;
        this.layout = vlayout;
        layout.isAutoResize = true;
    }

    void isAlignX(bool isAlign)
    {
        layout.isAlignX = isAlign;
    }

    bool isAlignX()
    {
        return layout.isAlignX;
    }

    double spacing()
    {
        return _spacing;
    }

    void spacing(double value)
    {
        _spacing = value;
        if (auto vlayout = cast(VerticalLayout) layout)
        {
            vlayout.spacing = value;
        }
    }
}

unittest
{
    import deltotum.kit.sprites.sprite : Sprite;
    import deltotum.math.geom.insets : Insets;

    auto sp1 = new Sprite;
    sp1.width = 100;
    sp1.height = 200;

    auto container1 = new VBox;
    container1.add(sp1);
    container1.update(0);

    assert(container1.width == sp1.width);
    assert(container1.height == sp1.height);
}
