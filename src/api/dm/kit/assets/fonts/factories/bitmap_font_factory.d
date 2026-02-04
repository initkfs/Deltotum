module api.dm.kit.assets.fonts.factories.bitmap_font_factory;

import api.dm.kit.components.graphic_component : GraphicComponent;
import api.dm.com.graphics.com_font : ComFontHinting, ComFont;
import api.dm.com.graphics.com_surface : ComSurface;
import api.dm.kit.assets.fonts.glyphs.glyph : Glyph;
import api.core.utils.factories : ProviderFactory;

import api.dm.com.graphics.com_font : ComFont;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.graphics.colors.rgba : RGBA;

import api.dm.kit.assets.fonts.bitmaps.bitmap_font : BitmapFont;
import api.dm.kit.i18n.langs.alphabets.alphabet : Alphabet;
import api.math.geom2.rect2 : Rect2f;
import api.math.geom2.vec2 : Vec2f;

import std.string : toStringz;
import std.uni : byGrapheme;
import std.utf : toUTFz;
import std.stdio;

import Math = api.math;

/**
 * Authors: initkfs
 */
class BitmapFontFactory : GraphicComponent
{
    ProviderFactory!ComSurface comSurfaceProvider;

    //TODO correct size?
    enum size_t defaultFontTextureWidth = 400;
    enum size_t defaultFontTextureHeight = 400;

    this(ProviderFactory!ComSurface comSurfaceProvider)
    {
        this.comSurfaceProvider = comSurfaceProvider;
    }

    import api.dm.lib.freetype.native;
    import csdl;

    void renderText(ComSurface surface, dchar[] text, FT_Face face)
    {
        import api.dm.kit.graphics.colors.rgba : RGBA;

        auto color = RGBA.white;

        int minW = 1;
        int minH = 1;

        int ascent = cast(int)(face.size.metrics.ascender >> 6);
        int descent = cast(int)(face.size.metrics.descender >> 6);

        int surfaceHeight = ascent - descent;

        int surfaceWidth = 0;
        foreach (dchar p; text)
        {
            int codep = cast(int) p;

            if (FT2_FT_Load_Char(face, codep, FT_LOAD_NO_BITMAP))
            {
                continue;
            }

            surfaceWidth += (face.glyph.advance.x >> 6);
        }

        if (surfaceWidth == 0)
        {
            surfaceWidth = minW;
        }

        if (surfaceHeight == 0)
        {
            surfaceHeight = minH;
        }

        if (const err = surface.createRGBA32(surfaceWidth, surfaceHeight))
        {

        }

        if (const err = surface.fill(0, 0, 0, 0))
        {

        }

        int baselineY = ascent;
        int penX = 0;

        foreach (dchar p; text)
        {
            auto codep = cast(int) p;
            //FT_LOAD_FORCE_AUTOHINT
            if (FT2_FT_Load_Char(face, codep, FT_LOAD_RENDER  | FT_LOAD_TARGET_LCD))
            {
                continue;
            }

            FT_GlyphSlot slot = face.glyph;

            if (FT2_FT_Render_Glyph(slot, FT_Render_Mode.FT_RENDER_MODE_LCD))
            {
                continue;
            }

            FT_Bitmap* bitmap = &slot.bitmap;

            int drawX = penX + slot.bitmap_left;
            int drawY = baselineY - slot.bitmap_top;

            int logicalWidth = bitmap.width / 3;

            for (int row = 0; row < bitmap.rows; row++)
            {
                for (int col = 0; col < logicalWidth; col++)
                {
                    //For LCD
                    int base_idx = row * bitmap.pitch + col * 3;
                    ubyte r = bitmap.buffer[base_idx];
                    ubyte g = bitmap.buffer[base_idx + 1];
                    ubyte b = bitmap.buffer[base_idx + 2];

                    ubyte alpha = cast(ubyte)((r + g + b) / 3);
                    //ubyte alpha = bitmap.buffer[row * bitmap.pitch + col];
                    if (alpha == 0)
                        continue;

                    int x = drawX + col;
                    int y = drawY + row;

                    if (x < 0 || x >= surface.getWidth || y < 0 || y >= surface.getHeight)
                        continue;

                    // const ubyte ALPHA_THRESHOLD = 100;

                    // if (alpha < ALPHA_THRESHOLD)
                    // {
                    //     continue;
                    // }

                    if (alpha == ubyte.max)
                    {
                        if (const err = surface.setPixelRGBA(x, y, color.r, color.g, color.b, color
                                .aByte))
                        {

                        }
                        continue;
                    }

                    uint* pixel;

                    if (const err = surface.getPixel(x, y, pixel))
                    {

                    }

                    ubyte bgR, bgG, bgB, bgA;
                    if (const err = surface.getPixelRGBA(pixel, bgR, bgG, bgB, bgA))
                    {
                        bgR = 0;
                        bgG = 0;
                        bgB = 0;
                        bgA = 0;
                    }

                    // //float gamma = 1;
                    float a = alpha / 255.0f;
                    // //float a = Math.pow(alpha / 255.0f, gamma);
                    float invA = 1.0f - a;

                    ubyte outR = cast(ubyte)(color.r * a + bgR * invA);
                    ubyte outG = cast(ubyte)(color.g * a + bgG * invA);
                    ubyte outB = cast(ubyte)(color.b * a + bgB * invA);
                    ubyte outA = cast(ubyte) Math.max(alpha, bgA);

                    if (const err = surface.setPixelRGBA(x, y, outR, outG, outB, outA))
                    {

                    }
                }
            }

            penX += (slot.advance.x >> 6);
        }
    }

    BitmapFont generate(
        Alphabet[] alphabets,
        ComFont font,
        RGBA foregroundColor = RGBA.white,
        RGBA backgroundColor = RGBA.black,
        int fontTextureWidth = defaultFontTextureWidth,
        int fontTextureHeight = defaultFontTextureWidth
    )
    {
        assert(fontTextureWidth > 0);
        assert(fontTextureHeight > 0);

        auto bitmapFont = new BitmapFont;
        build(bitmapFont);
        bitmapFont.initialize;
        assert(bitmapFont.isInitializing);

        //TODO remove after testing
        import std.string : fromStringz;

        FT_Library library;

        if (const err = FT2_FT_Init_FreeType(&library))
        {
            logger.error("Font initilization error");
            return bitmapFont;
        }

        scope (exit)
        {
            FT2_FT_Done_FreeType(library);
        }

        if (const error = FT2_FT_Library_SetLcdFilter(library, FT_LcdFilter.FT_LCD_FILTER_LIGHT))
        {
            throw new Exception("LCD");
        }

        auto fontPath = font.getFontPath;

        FT_Face face;

        if (const err = FT2_FT_New_Face(library, fontPath.toStringz, 0, &face))
        {
            logger.error("Font face error");
            return bitmapFont;
        }

        scope (exit)
        {
            FT2_FT_Done_Face(face);
        }

        if (const err = FT2_FT_Select_Charmap(face, FT_ENCODING_UNICODE))
        {
            throw new Exception("unicode tag");
        }

        const fontSize = font.getFontSize;

        if (const err = FT2_FT_Set_Pixel_Sizes(face, 0, fontSize))
        {
            logger.error("Font size error");
        }

        //The size can be very large to create on a stack
        ComSurface fontMapSurface = comSurfaceProvider.getNew();
        if (const err = fontMapSurface.createRGBA32(fontTextureWidth, fontTextureHeight))
        {
            throw new Exception(err.toString);
        }

        //TODO background
        //SDL_SetColorKey(fontMapSurface.getObject, SDL_TRUE, SDL_MapRGBA(
        //        fontMapSurface.getObject.format, 0, 0, 0, 0));
        if (const err = fontMapSurface.setPixelIsTransparent(true, 0, 0, 0, 0))
        {
            throw new Exception(err.toString);
        }

        Rect2f glyphPosition;
        Glyph[] glyphs;

        if (const err = font.setHinting(ComFontHinting.normal))
        {
            logger.error(err);
        }

        foreach (alphabet; alphabets)
        {
            dstring allLetters = alphabet.allLetters;
            //TODO byGrapheme?

            import std.utf : toUTFz;

            foreach (i, dchar letter; allLetters)
            {
                dchar[1] letters = [letter];
                //TODO does SDL keep a reference?
                comSurfaceProvider.getNewScoped((glyphRepresentation) {

                    renderText(glyphRepresentation, letters[], face);

                    // const isErr = font.renderFont(glyphRepresentation, letters[], foregroundColor.r, foregroundColor.g, foregroundColor.b, foregroundColor
                    //     .aByte, backgroundColor.r, backgroundColor.g, backgroundColor.b, backgroundColor
                    //     .aByte);

                    // if (isErr)
                    // {
                    //     throw new Exception(isErr.toString);
                    // }

                    glyphPosition.width = glyphRepresentation.getWidth;
                    glyphPosition.height = glyphRepresentation.getHeight;

                    if (glyphPosition.x + glyphPosition.width >= fontTextureWidth)
                    {
                        glyphPosition.x = 0;

                        glyphPosition.y += glyphPosition.height + 1;

                        if (glyphPosition.y + glyphPosition.height >= fontTextureWidth)
                        {
                            throw new Exception("Font FactoryKit error, texture size too small");
                        }
                    }

                    //TODO special?
                    import std.uni : isWhite;
                    import std.algorithm.comparison : among;

                    bool isNewline;
                    bool isEmpty = letter.isWhite;
                    if (isEmpty)
                    {
                        //FIXME \r\n
                        isNewline = letter.among('\n', '\r',) != 0;
                    }

                    auto glyph = Glyph(letter, glyphPosition, Vec2f.init, alphabet, isEmpty, isNewline);

                    //TODO config?
                    if (glyph.grapheme == '𑑛')
                    {
                        bitmapFont.placeholder = glyph;
                    }

                    if (glyph.grapheme == '0')
                    {
                        bitmapFont.e0 = glyph;
                    }

                    glyphs ~= glyph;

                    if (const err = glyphRepresentation.copyTo(fontMapSurface, glyphPosition))
                    {
                        throw new Exception(err.toString);
                    }
                    glyphRepresentation.dispose;
                });

                glyphPosition.x += glyphPosition.width;
            }
        }

        bitmapFont.glyphs = glyphs;

        bitmapFont.loadFromSurface(fontMapSurface);
        fontMapSurface.dispose;

        bitmapFont.create;

        bitmapFont.blendModeBlend;

        return bitmapFont;
    }
}
