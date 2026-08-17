module api.dm.kit.assets.fonts.bitmaps.bitmap_font;

import api.dm.kit.sprites2d.textures.tex2d : Tex2d;
import api.dm.kit.assets.fonts.glyphs.glyph : Glyph;
import api.dm.com.graphics.com_tex: ComTex;

/**
 * Authors: initkfs
 */
class BitmapFont : Tex2d
{
    //TODO hash map
    Glyph[] glyphs;

    Glyph placeholder;
    Glyph e0;

    this(ComTex texture, Glyph[] glyphs = null)
    {
        super(texture);
        this.glyphs = glyphs;
    }

    this(Glyph[] glyphs = null)
    {
        this.glyphs = glyphs;
    }

    BitmapFont copyBitmap()
    {
        assert(texture);
        ComTex newTexture;
        if (const err = texture.copyToNew(newTexture))
        {
            throw new Exception(err.toString);
        }
        //TODO create from parent
        auto toTexture = new BitmapFont(newTexture, glyphs);
        toTexture.placeholder = placeholder;
        build(toTexture);
        toTexture.initialize;
        toTexture.create;
        return toTexture;
    }

}
