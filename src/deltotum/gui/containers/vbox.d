module deltotum.gui.containers.vbox;

import deltotum.gui.containers.container : Container;
import deltotum.kit.sprites.layouts.vlayout : VLayout;

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

        auto vlayout = new VLayout(_spacing);
        vlayout.isAlignX = false;
        this.layout = vlayout;
        layout.isAutoResize = true;
    }

    void isAlignX(bool isAlign)
    {
        assert(layout);

        if(layout){
            layout.isAlignX = isAlign;
            setInvalid;
        }
    }

    bool isAlignX()
    {
        assert(layout);
        if(!layout){
            return false;
        }
        return layout.isAlignX;
    }

    double spacing()
    {
        return _spacing;
    }

    void spacing(double value)
    {
        _spacing = value;
        if (auto vlayout = cast(VLayout) layout)
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
