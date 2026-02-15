module api.dm.gui.themes.icons.icon_bitmap_generator;

import api.dm.kit.assets.fonts.bitmaps.base_bitmap_font_factory : BaseBitmapFontFactory;
import api.dm.kit.assets.fonts.bitmaps.bitmap_font : BitmapFont;
import api.core.utils.factories : ProviderFactory;
import api.dm.com.graphics.com_surface : ComSurface;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.assets.fonts.glyphs.glyph : Glyph;
import api.dm.com.graphics.com_font : ComFont;
import api.math.geom2.rect2 : Rect2f;
import api.math.geom2.vec2 : Vec2f;

/**
 * Authors: initkfs
 */

class IconBitmapGenerator : BaseBitmapFontFactory
{
    BitmapFont generate(
        const(dchar[]) text,
        ComFont font,
        RGBA foregroundColor = RGBA.white,
        RGBA backgroundColor = RGBA.black,
        int fontTextureWidth = defaultFontTextureWidth * 3,
        int fontTextureHeight = defaultFontTextureWidth * 2
    )
    {
        assert(fontTextureWidth > 0);
        assert(fontTextureHeight > 0);

        auto bitmapFont = newBitmapFont;
        ComSurface fontMapSurface = newFontSurface(font, fontTextureWidth, fontTextureHeight);

        Rect2f glyphPosition;
        generateToSurface(text, fontMapSurface, font, (ref glyph, ref pos) {}, foregroundColor, backgroundColor, glyphPosition);

        bitmapFont.loadFromSurface(fontMapSurface);
        fontMapSurface.dispose;
        bitmapFont.create;
        bitmapFont.blendModeBlend;

        return bitmapFont;
    }
}
