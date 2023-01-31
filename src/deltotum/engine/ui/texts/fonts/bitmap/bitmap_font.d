module deltotum.engine.ui.texts.fonts.bitmap.bitmap_font;

import deltotum.engine.display.textures.texture : Texture;
import deltotum.engine.i18n.langs.glyph : Glyph;

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
