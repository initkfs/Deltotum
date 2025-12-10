module api.dm.lib.vips.native.v8.binddynamic;

/**
 * Authors: initkfs
 */
import api.dm.lib.vips.native.v8.types;
import api.core.utils.libs.dynamics.dynamic_loader : DynamicLoader;

//TODO remove
extern (C)
{
    struct GObject;
    void g_object_unref(GObject* object);
}

void _vips_destroy(void* ptr)
{
    g_object_unref(cast(GObject*) ptr);
}

extern (C) nothrow
{
    int function(const char* argv0) vips_init;
    void function() vips_shutdown;
    char* function() vips_error_buffer_copy;

    VipsImage* function(const char* name, ...) vips_image_new_from_file;
    VipsImage* function(void* buf, size_t len, const char* option_string, ...) vips_image_new_from_buffer;
    VipsImage* function(void* data, size_t size, int width, int height, int bands, VipsBandFormat format) vips_image_new_from_memory;
    int function(VipsImage* image, const char* name, ...) vips_image_write_to_file;
    int function(VipsImage* inImage, const char* suffix, void** buf,size_t* size, ...)vips_image_write_to_buffer;

    int function(const VipsImage* image) vips_image_get_width;
    int function(const VipsImage* image) vips_image_get_height;

    int function(VipsImage* left, VipsImage* right, VipsImage** outImage, ...) vips_add;
    int function(VipsImage* left, VipsImage* right, VipsImage** outImage, ...) vips_multiply;

    int function(VipsImage* inImage, VipsImage** outImage, double a, double b, ...) vips_linear1;
    int function(VipsImage* inImage, VipsImage** outImage, double sigma, ...) vips_gaussblur;
    int function(VipsImage* inImage, VipsImage** outImage, VipsImage* mask, ...) vips_conv;
    int function(VipsImage* inImage, VipsImage** outImage, double scale, ...) vips_resize;
}

class VipsLib : DynamicLoader
{
    override void bindAll()
    {
        bind(&vips_init, "vips_init");
        bind(&vips_shutdown, "vips_shutdown");
        bind(&vips_error_buffer_copy, "vips_error_buffer_copy");

        bind(&vips_image_new_from_file, "vips_image_new_from_file");
        bind(&vips_image_new_from_buffer, "vips_image_new_from_buffer");
        bind(&vips_image_new_from_memory, "vips_image_new_from_memory");
        bind(&vips_image_write_to_file, "vips_image_write_to_file");
        bind(&vips_image_write_to_buffer, "vips_image_write_to_buffer");

        bind(&vips_image_write_to_file, "vips_image_get_width");
        bind(&vips_image_new_from_file, "vips_image_get_height");

        bind(&vips_image_write_to_file, "vips_add");
        bind(&vips_image_new_from_file, "vips_multiply");

        bind(&vips_error_buffer_copy, "vips_linear1");
        bind(&vips_error_buffer_copy, "vips_gaussblur");
        bind(&vips_error_buffer_copy, "vips_conv");
        bind(&vips_error_buffer_copy, "vips_resize");
    }

    version (Windows)
    {
        const(char)[][1] paths = ["libvips.dll"];
    }
    else version (OSX)
    {
        const(char)[][1] paths = ["libvips.dylib"];
    }
    else version (Posix)
    {
        const(char)[][1] paths = ["libvips.so"];
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
        return 8;
    }

}
