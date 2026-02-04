module api.dm.lib.freetype.native.binddynamic;

/**
 * Authors: initkfs
 */
import api.dm.lib.freetype.native.types;
import api.core.utils.libs.dynamics.dynamic_loader : DynamicLoader;

extern (C) nothrow
{
    FT_Error function(FT_Library* alibrary) FT_Init_FreeType;
    FT_Error function(FT_Library library) FT_Done_FreeType;

    FT_Error function(FT_Library library, const char* filepathname, FT_Long face_index, FT_Face* aface) FT_New_Face;
    FT_Error function(FT_Face face) FT_Done_Face;

    FT_Error function(FT_Face face, FT_UInt pixel_width, FT_UInt pixel_height) FT_Set_Pixel_Sizes;
}

class FreeTypeLib : DynamicLoader
{
    bool isInit;

    protected
    {

    }

    override void bindAll()
    {
        bind(&FT_Init_FreeType, "FT_Init_FreeType");
        bind(&FT_Done_FreeType, "FT_Done_FreeType");

        bind(&FT_New_Face, "FT_New_Face");
        bind(&FT_Done_Face, "FT_Done_Face");

        bind(&FT_Set_Pixel_Sizes, "FT_Set_Pixel_Sizes");
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

    bool initialize(out string error)
    {
        return false;
    }

}
