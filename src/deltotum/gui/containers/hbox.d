module deltotum.gui.containers.hbox;

import deltotum.gui.containers.container : Container;
import deltotum.kit.sprites.layouts.hlayout : HLayout;
import deltotum.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
class HBox : Container
{
    private
    {
        double _spacing;
    }

    this(double spacing = 0) pure
    {
        import std.exception : enforce;
        import std.conv : text;

        enforce(spacing >= 0, text("Horizontal spacing must be positive value or 0: ", spacing));
        this._spacing = spacing;

        auto hlayout = new HLayout(_spacing);
        hlayout.isAlignY = false;
        hlayout.isAutoResize = true;
        this.layout = hlayout;
    }

    double spacing()
    {
        return _spacing;
    }

    void spacing(double value)
    {
        _spacing = value;
        if (auto hLayout = cast(HLayout) layout)
        {
            hLayout.spacing = value;
        }
    }

    override void enableInsets()
    {
        //TODO lazy flag
        super.enableInsets;
        enableSpacing;
    }

    //TODO remove duplication with vbox
    void enableSpacing()
    {
        if (!hasGraphics || !graphics.theme)
        {
            throw new Exception(
                "Unable to enable spacing: graphic or theme is null. Perhaps the component is not built correctly");
        }
        const value = graphics.theme.controlSpacing;
        spacing = value;
    }
}
