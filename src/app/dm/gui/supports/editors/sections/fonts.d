module app.dm.gui.supports.editors.sections.fonts;

import app.dm.gui.controls.control : Control;
import app.dm.math.rect2d : Rect2d;

import std.stdio;

/**
 * Authors: initkfs
 */
class Fonts : Control
{
    this()
    {
        import app.dm.kit.sprites.layouts.hlayout : HLayout;

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

        auto fontSmallTexture = asset.fontBitmapSmall.copy;
        fontSmallTexture.isDrawBounds = true;
        add(fontSmallTexture);

        auto fontLargeTexture = asset.fontBitmapLarge.copy;
        fontLargeTexture.isDrawBounds = true;
        add(fontLargeTexture);

    }
}
