module deltotum.ui.texts.fonts.bitmap.bitmap_font;

import deltotum.toolkit.display.textures.texture : Texture;
import deltotum.toolkit.i18n.langs.glyph : Glyph;

/**
 * Authors: initkfs
 */
class BitmapFont : Texture
{

    Glyph[] glyphs;

    this(Glyph[] glyphs)
    {
        super();
        this.glyphs = glyphs;
    }

}
