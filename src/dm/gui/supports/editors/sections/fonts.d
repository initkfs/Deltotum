module dm.gui.supports.editors.sections.fonts;

import dm.gui.controls.control : Control;
import dm.math.shapes.rect2d : Rect2d;

import std.stdio;

/**
 * Authors: initkfs
 */
class Fonts : Control
{
    this()
    {
        import dm.kit.sprites.layouts.hlayout : HLayout;

        layout = new HLayout(5);
        layout.isAutoResize = true;
        isBackground = false;
        layout.isAlignY = false;
    }

    override void initialize()
    {
        super.initialize;
        enablePadding;
    }

    override void create()
    {
        super.create;

        auto defaultFontTexture = asset.fontBitmap.copy;
        defaultFontTexture.isDrawBounds = true;
        add(defaultFontTexture);

    }
}
