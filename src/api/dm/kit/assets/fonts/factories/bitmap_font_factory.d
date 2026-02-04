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

    void RenderText(ComSurface surface, dchar[] text, FT_Face face)
    {
        import api.dm.kit.graphics.colors.rgba : RGBA;

        auto color = RGBA.white;

        int maxW = 1;
        int maxH = 1;

        foreach (dchar p; text)
        {
            int codep = cast(int) p;

            if (FT2_FT_Load_Char(face, codep, FT_LOAD_NO_BITMAP))
            {
                continue;
            }

            FT_Glyph glyph;
            if (const err = FT2_FT_Get_Glyph(face.glyph, &glyph))
            {
                throw new Exception("glyph");
            }

            FT_BBox bbox;
            FT2_FT_Glyph_Get_CBox(glyph, FT_Glyph_BBox_Mode.FT_GLYPH_BBOX_PIXELS, &bbox);

            auto width = bbox.xMax - bbox.xMin;
            auto height = bbox.yMax - bbox.yMin;
            if (width > maxW)
            {
                maxW = cast(int) width;
            }
            if (height > maxH)
            {
                maxH = cast(int) height;
            }
        }

        int surface_width = maxW;
        int surface_height = maxH;

        import std;

        if (const err = surface.createRGBA32(surface_width, surface_height))
        {

        }

        foreach (dchar p; text)
        {
            auto codep = cast(int) p;
            if (FT2_FT_Load_Char(face, codep, FT_LOAD_RENDER))
            {
                continue;
            }

            FT_Glyph glyph;
            if (const err = FT2_FT_Get_Glyph(face.glyph, &glyph))
            {
                throw new Exception("glyph");
            }

            FT_Glyph image;
            if (const err = FT2_FT_Glyph_Copy(glyph, &image))
            {
                throw new Exception("glyph copy");
            }

            FT_Vector origin;
            origin.x = 0;
            origin.y = 0;

            if (const err = FT2_FT_Glyph_To_Bitmap(&image, FT_Render_Mode.FT_RENDER_MODE_NORMAL, &origin, 1))
            {

            }

            FT_BitmapGlyph bitmap_glyph = cast(FT_BitmapGlyph) image;
            FT_Bitmap* bitmap = &bitmap_glyph.bitmap;

            int draw_x = bitmap_glyph.left;
            int draw_y = surface.getHeight - bitmap_glyph.top;

            for (int row = 0; row < bitmap.rows; row++)
            {
                for (int col = 0; col < bitmap.width; col++)
                {
                    ubyte alpha = bitmap.buffer[row * bitmap.pitch + col];
                    if (alpha == 0)
                        continue;

                    int x = draw_x + col;
                    int y = draw_y + row;

                    if (x < 0 || x >= surface.getWidth || y < 0 || y >= surface.getHeight)
                        continue;

                    if (const err = surface.setPixelRGBA(x, y, color.r, color.g, color.b, alpha))
                    {
                    }
                }
            }

            FT2_FT_Done_Glyph(image);

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

                    RenderText(glyphRepresentation, letters[], face);

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

    // BitmapFont generate(
    //     Alphabet[] alphabets,
    //     ComFont font,
    //     RGBA foregroundColor = RGBA.white,
    //     RGBA backgroundColor = RGBA.black,
    //     int fontTextureWidth = defaultFontTextureWidth,
    //     int fontTextureHeight = defaultFontTextureWidth
    // )
    // {
    //     assert(fontTextureWidth > 0);
    //     assert(fontTextureHeight > 0);

    //     //The size can be very large to create on a stack
    //     ComSurface fontMapSurface = comSurfaceProvider.getNew();
    //     if (const err = fontMapSurface.createRGBA32(fontTextureWidth, fontTextureHeight))
    //     {
    //         throw new Exception(err.toString);
    //     }

    //     //TODO background
    //     //SDL_SetColorKey(fontMapSurface.getObject, SDL_TRUE, SDL_MapRGBA(
    //     //        fontMapSurface.getObject.format, 0, 0, 0, 0));
    //     if (const err = fontMapSurface.setPixelIsTransparent(true, 0, 0, 0, 0))
    //     {
    //         throw new Exception(err.toString);
    //     }

    //     Rect2f glyphPosition;
    //     Glyph[] glyphs;

    //     if (const err = font.setHinting(ComFontHinting.normal))
    //     {
    //         logger.error(err);
    //     }

    //     auto bitmapFont = new BitmapFont;
    //     build(bitmapFont);
    //     bitmapFont.initialize;
    //     assert(bitmapFont.isInitializing);

    //     foreach (alphabet; alphabets)
    //     {
    //         dstring allLetters = alphabet.allLetters;
    //         //TODO byGrapheme?
    //         foreach (i, dchar letter; allLetters)
    //         {
    //             const(dchar[1]) letters = [letter];
    //             //TODO does SDL keep a reference?
    //             comSurfaceProvider.getNewScoped((glyphRepresentation) {
    //                 const isErr = font.renderFont(glyphRepresentation, letters[], foregroundColor.r, foregroundColor.g, foregroundColor.b, foregroundColor
    //                     .aByte, backgroundColor.r, backgroundColor.g, backgroundColor.b, backgroundColor
    //                     .aByte);

    //                 if (isErr)
    //                 {
    //                     throw new Exception(isErr.toString);
    //                 }

    //                 glyphPosition.width = glyphRepresentation.getWidth;
    //                 glyphPosition.height = glyphRepresentation.getHeight;

    //                 if (glyphPosition.x + glyphPosition.width >= fontTextureWidth)
    //                 {
    //                     glyphPosition.x = 0;

    //                     glyphPosition.y += glyphPosition.height + 1;

    //                     if (glyphPosition.y + glyphPosition.height >= fontTextureWidth)
    //                     {
    //                         throw new Exception("Font FactoryKit error, texture size too small");
    //                     }
    //                 }

    //                 //TODO special?
    //                 import std.uni : isWhite;
    //                 import std.algorithm.comparison : among;

    //                 bool isNewline;
    //                 bool isEmpty = letter.isWhite;
    //                 if (isEmpty)
    //                 {
    //                     //FIXME \r\n
    //                     isNewline = letter.among('\n', '\r',) != 0;
    //                 }

    //                 auto glyph = Glyph(letter, glyphPosition, Vec2f.init, alphabet, isEmpty, isNewline);

    //                 //TODO config?
    //                 if (glyph.grapheme == '𑑛')
    //                 {
    //                     bitmapFont.placeholder = glyph;
    //                 }

    //                 if (glyph.grapheme == '0')
    //                 {
    //                     bitmapFont.e0 = glyph;
    //                 }

    //                 glyphs ~= glyph;

    //                 if (const err = glyphRepresentation.copyTo(fontMapSurface, glyphPosition))
    //                 {
    //                     throw new Exception(err.toString);
    //                 }
    //                 glyphRepresentation.dispose;
    //             });

    //             glyphPosition.x += glyphPosition.width;
    //         }
    //     }

    //     bitmapFont.glyphs = glyphs;

    //     bitmapFont.loadFromSurface(fontMapSurface);
    //     fontMapSurface.dispose;

    //     bitmapFont.create;

    //     bitmapFont.blendModeBlend;

    //     return bitmapFont;
    // }
}
