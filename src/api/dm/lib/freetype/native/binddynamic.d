module api.dm.lib.freetype.native.binddynamic;

/**
 * Authors: initkfs
 */
import api.dm.lib.freetype.native.types;
import api.core.utils.libs.dynamics.dynamic_loader : DynamicLoader;

extern (C) nothrow
{
    const(char*) function(FT_Error error_code) FT2_FT_Error_String;

    FT_Error function(FT_Library* alibrary) FT2_FT_Init_FreeType;
    FT_Error function(FT_Library library) FT2_FT_Done_FreeType;

    FT_Error function(FT_Library library, FT_LcdFilter filter) FT2_FT_Library_SetLcdFilter;

    FT_Error function(FT_Library library, const char* filepathname, FT_Long face_index, FT_Face* aface) FT2_FT_New_Face;
    FT_Error function(FT_Face face) FT2_FT_Done_Face;

    FT_Error function(FT_Face face, FT_UInt pixel_width, FT_UInt pixel_height) FT2_FT_Set_Pixel_Sizes;

    FT_Error function(FT_Face face, FT_ULong char_code, FT_Int32 load_flags) FT2_FT_Load_Char;

    FT_Error function(FT_Glyph glyph, FT_UInt bbox_mode, FT_BBox* acbox) FT2_FT_Glyph_Get_CBox;
    FT_Error function(FT_Glyph* the_glyph, FT_Render_Mode render_mode, const FT_Vector* origin, FT_Bool destroy) FT2_FT_Glyph_To_Bitmap;
    FT_Error function(FT_GlyphSlot slot, FT_Glyph* aglyph) FT2_FT_Get_Glyph;
    FT_Error function(FT_Glyph source,
        FT_Glyph* target) FT2_FT_Glyph_Copy;
    FT_Error function(FT_Glyph) FT2_FT_Done_Glyph;
    FT_Error function(FT_GlyphSlot slot, FT_Render_Mode render_mode) FT2_FT_Render_Glyph;

    FT_UInt function(FT_Face face, FT_ULong charcode) FT2_FT_Get_Char_Index;
    FT_Error function(FT_Face face, FT_Encoding encoding) FT2_FT_Select_Charmap;

}

class FreeTypeLib : DynamicLoader
{
    protected
    {
        FT_Library _library;
    }

    override void bindAll()
    {
        bind(&FT2_FT_Error_String, "FT_Error_String");
        bind(&FT2_FT_Init_FreeType, "FT_Init_FreeType");
        bind(&FT2_FT_Done_FreeType, "FT_Done_FreeType");

        bind(&FT2_FT_Library_SetLcdFilter, "FT_Library_SetLcdFilter");

        bind(&FT2_FT_New_Face, "FT_New_Face");
        bind(&FT2_FT_Done_Face, "FT_Done_Face");

        bind(&FT2_FT_Set_Pixel_Sizes, "FT_Set_Pixel_Sizes");

        bind(&FT2_FT_Load_Char, "FT_Load_Char");

        bind(&FT2_FT_Glyph_Get_CBox, "FT_Glyph_Get_CBox");
        bind(&FT2_FT_Glyph_To_Bitmap, "FT_Glyph_To_Bitmap");
        bind(&FT2_FT_Get_Glyph, "FT_Get_Glyph");
        bind(&FT2_FT_Glyph_Copy, "FT_Glyph_Copy");
        bind(&FT2_FT_Done_Glyph, "FT_Done_Glyph");
        bind(&FT2_FT_Render_Glyph, "FT_Render_Glyph");

        bind(&FT2_FT_Get_Char_Index, "FT_Get_Char_Index");
        bind(&FT2_FT_Select_Charmap, "FT_Select_Charmap");
    }

    version (Windows)
    {
        const(char)[][1] paths = [
            "libfreetype.dll"
        ];
    }
    else version (OSX)
    {
        const(char)[][1] paths = [
            "libfreetype.dylib"
        ];
    }
    else version (Posix)
    {
        const(char)[][1] paths = [
            "libfreetype.so"
        ];
    }
    else
    {
        const(char)[0][0] paths;
    }

    override const(char[][]) libPaths()
    {
        return paths;
    }

    override int libVersion()
    {
        return 2;
    }

    override string libVersionStr()
    {
        return null;
    }

    bool isInit() => _library !is null;

    bool initialize()
    {
        //TODO dispose when reinit
        if (const err = FT2_FT_Init_FreeType(&_library))
        {
            _library = null;
            return false;
        }
        return true;
    }

    bool setLCDFilter()
    {
        assert(library);
        if (const error = FT2_FT_Library_SetLcdFilter(library, FT_LcdFilter.FT_LCD_FILTER_LIGHT))
        {
            return false;
        }
        return true;
    }

    bool dispose()
    {
        if (!_library)
        {
            return false;
        }
        FT2_FT_Done_FreeType(_library);
        _library = null;
        return true;
    }

    FT_Library library() nothrow
    {
        assert(_library);
        return _library;
    }

}
