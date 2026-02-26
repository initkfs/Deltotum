module api.dm.lib.libpng.native.binddynamic;

/**
 * Authors: initkfs
 */
import api.core.contexts.libs.dynamics.dynamic_loader : DynamicLoader;
import api.dm.lib.libpng.native.types;

extern (C) nothrow
{
    int function(png_imagep image, const char* file_name) png_image_begin_read_from_file;
    int function(png_imagep image, png_const_voidp memory, size_t size) png_image_begin_read_from_memory;
    int function(png_imagep image,
        png_const_colorp background, void* buffer, png_int_32 row_stride,
        void* colormap) png_image_finish_read;
    void function(png_imagep image) png_image_free;
    int function(png_imagep image,
        const char* file, int convert_to_8bit, const void* buffer,
        png_int_32 row_stride, const void* colormap) png_image_write_to_file;
}

class PngLib : DynamicLoader
{
    protected
    {

    }

    override void bindAll()
    {
        bind(&png_image_begin_read_from_file, "png_image_begin_read_from_file");
        bind(&png_image_begin_read_from_memory, "png_image_begin_read_from_memory");
        bind(&png_image_finish_read, "png_image_finish_read");
        bind(&png_image_free, "png_image_free");
        bind(&png_image_write_to_file, "png_image_write_to_file");
    }

    version (Windows)
    {
        string[] paths = [
            "libpng.dll"
        ];
    }
    else version (OSX)
    {
        string[] paths = [
            "libpng.dylib"
        ];
    }
    else version (Posix)
    {
        string[] paths = [
            "libpng.so"
        ];
    }
    else
    {
        string[] paths;
    }

    override string[] libPaths()
    {
        return paths;
    }
}
