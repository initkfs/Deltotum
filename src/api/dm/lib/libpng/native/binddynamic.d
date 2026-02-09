module api.dm.lib.libpng.native.binddynamic;

/**
 * Authors: initkfs
 */
import api.core.utils.libs.dynamics.dynamic_loader : DynamicLoader;
import api.dm.lib.libpng.native.types;

extern (C) nothrow
{
    int function(png_imagep image, const char* file_name) png_image_begin_read_from_file;
    int function(png_imagep image,
        png_const_colorp background, void* buffer, png_int_32 row_stride,
        void* colormap) png_image_finish_read;
    void function(png_imagep image) png_image_free;
    int function(png_imagep image,
        const char* file, int convert_to_8bit, const void* buffer,
        png_int_32 row_stride, const void* colormap) png_image_write_to_file;
}

class LibpngLib : DynamicLoader
{
    bool isInit;

    protected
    {

    }

    override void bindAll()
    {
        bind(&png_image_begin_read_from_file, "png_image_begin_read_from_file");
        bind(&png_image_finish_read, "png_image_finish_read");
        bind(&png_image_free, "png_image_free");
        bind(&png_image_write_to_file, "png_image_write_to_file");
    }

    version (Windows)
    {
        const(char)[][1] paths = [
            "libpng.dll"
        ];
    }
    else version (OSX)
    {
        const(char)[][1] paths = [
            "libpng.dylib"
        ];
    }
    else version (Posix)
    {
        const(char)[][1] paths = [
            "libpng.so"
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
        return 0;
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
