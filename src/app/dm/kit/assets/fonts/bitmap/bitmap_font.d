module app.dm.kit.assets.fonts.bitmap.bitmap_font;

import app.dm.kit.sprites.textures.texture : Texture;
import app.dm.kit.assets.fonts.glyphs.glyph : Glyph;
import app.dm.com.graphics.com_texture: ComTexture;

/**
 * Authors: initkfs
 */
class BitmapFont : Texture
{
    //TODO hash map
    Glyph[] glyphs;

    Glyph placeholder;

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
        if (const err = texture.copy(newTexture))
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
