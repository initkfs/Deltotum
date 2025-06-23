module api.dm.kit.assets.fonts.bitmaps.bitmap_font;

import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.assets.fonts.glyphs.glyph : Glyph;
import api.dm.com.graphic.com_texture: ComTexture;

/**
 * Authors: initkfs
 */
class BitmapFont : Texture2d
{
    //TODO hash map
    Glyph[] glyphs;

    Glyph placeholder;
    Glyph e0;

    this(ComTexture texture, Glyph[] glyphs = null)
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
        ComTexture newTexture;
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
