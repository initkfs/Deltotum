module api.dm.kit.sprites2d.images.codecs.jpeg_image_codec;

import api.dm.lib.libjpeg.native.types;
import api.dm.lib.libjpeg.native.binddynamic;
import api.dm.kit.sprites2d.images.codecs.base_image_codec : BaseImageCodec;
import api.dm.com.com_result : ComResult;
import api.dm.com.graphics.com_surface : ComSurface;
import core.stdc.stdlib : malloc, free;

class JpegImageCodec : BaseImageCodec
{
    //hi 85-95, mid 75-85, artefacts 50-75
    size_t quality = 40;

    protected
    {
        ubyte[] _buffer;
    }

    bool isSupport(string path) nothrow
    {
        return isSupportedExt(path, ".jpeg") || isSupportedExt(path, ".jpg");
    }

    bool isSupport(const(ubyte[]) buff) nothrow
    {
        return buff.length >= 2 && buff[0] == 0xFF && buff[1] == 0xD8;
    }

    override ComResult load(const(ubyte[]) contentRaw, ComSurface surface) nothrow
    {
        assert(tjInitDecompress);

        tjhandle decompressor = tjInitDecompress();
        if (!decompressor)
        {
            return ComResult.error("Error initialize decompressor:" ~ lastError);
        }

        scope (exit)
        {
            tjDestroy(decompressor);
        }

        assert(tjDecompressHeader3);

        int w, h, jpegSubsamp, jpegColorspace;
        if (tjDecompressHeader3(decompressor, contentRaw.ptr, contentRaw.length,
                &w, &h, &jpegSubsamp, &jpegColorspace))
        {
            return ComResult.error("Error decompress header: " ~ lastError);
        }

        if (w == 0 || h == 0)
        {
            return ComResult.error("Image size must not be 0");
        }

        size_t pixelSize = 3; // TJPF.TJPF_RGB
        size_t pitch = w * pixelSize;
        //size_t bufferSize = h * pitch;

        // ubyte* imageBufferPtr = cast(ubyte*) malloc(bufferSize);
        // if (!imageBufferPtr)
        // {
        //     return ComResult.error("Error memory allocation for image buffer");
        // }

        // ubyte[] imageBuffer = imageBufferPtr[0 .. bufferSize];

        if (const err = surface.createRGB24(w, h))
        {
            return err;
        }

        if (surface.getPitch != pitch)
        {
            return ComResult.error("Surface pitch invalid");
        }

        if (surface.getWidth != w || surface.getHeight != h)
        {
            return ComResult.error("Surface size invalid");
        }

        if (tjDecompress2(decompressor, contentRaw.ptr, contentRaw.length,
                cast(ubyte*) surface.pixels,
                w, surface.getPitch, h,
                TJPF.TJPF_RGB, TJFLAG_ACCURATEDCT) != 0)
        {
            return ComResult.error("Error decompress image to buffer: " ~ lastError);
        }

        return ComResult.success;
    }

    ComResult save(string path, ComSurface surface) nothrow
    {
        auto pixelFormat = TJPF.TJPF_RGB;
        auto jpegSubsampOut = TJSAMP.TJSAMP_422;

        tjhandle compressor = tjInitCompress();
        if (!compressor)
        {
            return ComResult.error("Error init compressor");
        }

        scope (exit)
        {
            tjDestroy(compressor);
        }

        ubyte* jpegBufOut;
        ulong jpegSizeOut;

        int result = tjCompress2(compressor,
            cast(ubyte*) surface.pixels,
            surface.getWidth,
            surface.getPitch,
            surface.getHeight,
            pixelFormat,
            &jpegBufOut,
            &jpegSizeOut,
            jpegSubsampOut,
            cast(int) quality,
            TJFLAG_ACCURATEDCT);
        if (result != 0)
        {
            return ComResult.error("Error compress image from buffer: " ~ lastError);
        }

        scope (exit)
        {
            tjFree(jpegBufOut);
        }

        return saveToFile(path, jpegBufOut[0 .. jpegSizeOut]);
    }

    string lastError() nothrow
    {
        import std.string : fromStringz;

        return tjGetErrorStr2().fromStringz.idup;
    }

}
