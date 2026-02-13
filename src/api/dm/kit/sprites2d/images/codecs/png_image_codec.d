module api.dm.kit.sprites2d.images.codecs.png_image_codec;

import api.dm.lib.libpng.native;

import api.dm.kit.sprites2d.images.codecs.base_image_codec : BaseImageCodec;
import api.dm.com.com_result : ComResult;
import api.dm.com.graphics.com_surface : ComSurface;
import core.stdc.stdlib : malloc, free;
import std.string : toStringz, fromStringz;

class PngImageCodec : BaseImageCodec
{
    bool isSupport(const(ubyte[]) buff) nothrow
    {
        static immutable ubyte[8] pngSignature = [
            0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A
        ];

        if (buff.length < pngSignature.length)
        {
            return false;
        }

        return buff[0 .. pngSignature.length] == pngSignature;
    }

    bool isSupport(string path) nothrow => isSupportedExt(path, ".png");

    override ComResult load(const(ubyte[]) contentRaw, ComSurface surface) nothrow
    {
        png_image image;
        image._version = PNG_IMAGE_VERSION;

        if (!png_image_begin_read_from_memory(&image, contentRaw.ptr, contentRaw.length))
        {
            return ComResult.error(
                "Error reading png from memory: " ~ lastError(image));
        }

        scope (exit)
        {
            png_image_free(&image);
        }

        image.format = PNG_FORMAT_RGBA;

        if (const err = surface.createRGBA32(image.width, image.height))
        {
            return err;
        }

        if (surface.getWidth != image.width || surface.getHeight != image.height)
        {
            return ComResult.error("Surface size invalid");
        }

        if (png_image_finish_read(&image, null, surface.pixels,
                surface.getPitch, null) == 0)
        {
            return ComResult.error("Error saving image to bufer: " ~ lastError(image));
        }

        return ComResult.success;
    }

    ComResult save(string path, ComSurface surface) nothrow
    {
        if (surface.getWidth == 0 || surface.getHeight == 0)
        {
            return ComResult.error("Surface size must not be 0");
        }

        png_image saveImage;
        saveImage._version = PNG_IMAGE_VERSION;
        saveImage.width = surface.getWidth;
        saveImage.height = surface.getHeight;
        saveImage.format = PNG_FORMAT_RGBA;
        saveImage.flags = 0;
        saveImage.colormap_entries = 0;

        png_uint_32 stride = cast(png_uint_32) surface.getPitch;

        if (png_image_write_to_file(&saveImage, path.toStringz, 0,
                surface.pixels, stride, null) == 0)
        {
            return ComResult.error("Error saving png to file: " ~ lastError(saveImage));
        }
        return ComResult.success;
    }

    string lastError(png_image image) nothrow => image.message.fromStringz.idup;
}
