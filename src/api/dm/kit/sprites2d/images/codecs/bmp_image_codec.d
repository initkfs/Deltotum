module api.dm.kit.sprites2d.images.codecs.bmp_image_codec;

import api.dm.kit.sprites2d.images.codecs.base_image_codec : BaseImageCodec;
import api.dm.com.com_result : ComResult;
import api.dm.com.graphics.com_surface : ComSurface;

/** 
 * TODO need refactor
 */
class BmpImageCodec : BaseImageCodec
{
    bool isSupport(const(ubyte[]) buff) nothrow
    {
        static immutable ubyte[2] bmpSignature = ['B', 'M'];

        if (buff.length < bmpSignature.length)
        {
            return false;
        }

        return buff[0 .. bmpSignature.length] == bmpSignature;
    }

    bool isSupport(string path) nothrow => isSupportedExt(path, ".bmp");

    override ComResult load(const(ubyte[]) contentRaw, ComSurface surface) nothrow
    {
        import std.bitmanip : littleEndianToNative;

        enum minHeaderLen = 54;
        if (contentRaw.length < minHeaderLen)
        {
            return ComResult.error("Invalid BMP file: too small");
        }

        //uint fileSize = littleEndianToNative!uint(contentRaw[2 .. 6]);
        uint dataOffset = littleEndianToNative!uint(contentRaw[10 .. 14]);
        //uint headerSize = littleEndianToNative!uint(contentRaw[14 .. 18]);
        int width = littleEndianToNative!int(contentRaw[18 .. 22]);
        int height = littleEndianToNative!int(contentRaw[22 .. 26]);
        //ushort planes = littleEndianToNative!ushort(contentRaw[26 .. 28]);
        ushort bpp = littleEndianToNative!ushort(contentRaw[28 .. 30]); // bits per pixel
        uint compression = littleEndianToNative!uint(contentRaw[30 .. 34]);

        if (width <= 0 || height == 0)
        {
            return ComResult.error("Invalid BMP dimensions");
        }

        if (compression != 0)
        {
            return ComResult.error("Compressed BMP not supported");
        }

        if (bpp != 24 && bpp != 32)
        {
            return ComResult.error("Only 24/32-bit BMP supported");
        }

        int absHeight = height > 0 ? height : -height;
        if (const err = surface.createRGBA32(width, absHeight))
        {
            return err;
        }

        int bytesPerPixel = bpp / 8;
        int bmpStride = (width * bytesPerPixel + 3) & ~3; // align 4 bytes

        if (dataOffset + bmpStride * absHeight > contentRaw.length)
        {
            return ComResult.error("BMP data truncated");
        }

        ubyte[] wholeBuffer = (cast(ubyte*) surface.pixels)[0 .. surface.getHeight * surface
            .getPitch];

        // row down to up if height > 0
        bool topDown = height < 0;

        foreach (y; 0 .. height)
        {
            int srcY = topDown ? y : (height - 1 - y);
            ubyte[] dstRow = wholeBuffer[y * surface.getPitch .. (y + 1) * surface.getPitch];
            size_t srcOffset = dataOffset + srcY * bmpStride;
            const(ubyte)[] srcRow = contentRaw[srcOffset .. srcOffset + bmpStride];

            foreach (x; 0 .. width)
            {
                ubyte[] dstPixel = dstRow[x * 4 .. x * 4 + 4];
                const(ubyte)[] srcPixel = srcRow[x * bytesPerPixel .. x * bytesPerPixel + bytesPerPixel];

                if (bpp == 24)
                {
                    dstPixel[0] = srcPixel[2]; // R
                    dstPixel[1] = srcPixel[1]; // G
                    dstPixel[2] = srcPixel[0]; // B
                    dstPixel[3] = 0xFF; // A
                }
                else // bpp == 32
                {
                    dstPixel[0] = srcPixel[2]; // R
                    dstPixel[1] = srcPixel[1]; // G
                    dstPixel[2] = srcPixel[0]; // B
                    dstPixel[3] = srcPixel[3]; // A
                }
            }
        }

        return ComResult.success;
    }

    ComResult save(string path, ComSurface surface) nothrow
    {
        if (surface.getWidth == 0 || surface.getHeight == 0)
        {
            return ComResult.error("Surface size must not be 0");
        }

        import std.bitmanip : nativeToLittleEndian;
        import std.file : write;
        import std.conv : to;

        int width = surface.getWidth;
        int height = surface.getHeight;

        bool topDown = false;

        // BMP 32 bpe (RGBA -> BGRA)
        int bytesPerPixel = 4;
        int bmpStride = (width * bytesPerPixel + 3) & ~3; //align 4 bytes
        int imageSize = bmpStride * height;

        uint fileHeaderSize = 14;
        uint infoHeaderSize = 40;
        uint dataOffset = fileHeaderSize + infoHeaderSize;
        uint fileSize = dataOffset + imageSize;

        import core.stdc.stdlib : malloc, free;

        ubyte* bmpBufferPtr = cast(ubyte*) malloc(fileSize);
        if (!bmpBufferPtr)
        {
            return ComResult.error("Error allocate bmp buffer");
        }

        scope (exit)
        {
            free(bmpBufferPtr);
        }

        ubyte[] bmpBuffer = bmpBufferPtr[0 .. fileSize];

        // File Header
        bmpBuffer[0] = 'B';
        bmpBuffer[1] = 'M';
        bmpBuffer[2 .. 6] = nativeToLittleEndian!uint(fileSize);
        bmpBuffer[6 .. 8] = nativeToLittleEndian!ushort(0); // reserved1 (2 байта)
        bmpBuffer[8 .. 10] = nativeToLittleEndian!ushort(0); // reserved2 (2 байта)
        bmpBuffer[10 .. 14] = nativeToLittleEndian!uint(dataOffset);

        // Info Header
        bmpBuffer[14 .. 18] = nativeToLittleEndian!uint(infoHeaderSize);
        bmpBuffer[18 .. 22] = nativeToLittleEndian!int(width);
        bmpBuffer[22 .. 26] = nativeToLittleEndian!int(topDown ? -height : height);
        bmpBuffer[26 .. 28] = nativeToLittleEndian!ushort(1); // planes
        bmpBuffer[28 .. 30] = nativeToLittleEndian!ushort(32); // bpp (32 бита)
        bmpBuffer[30 .. 34] = nativeToLittleEndian!uint(0); // compression (BI_RGB)
        bmpBuffer[34 .. 38] = nativeToLittleEndian!uint(imageSize);
        bmpBuffer[38 .. 42] = nativeToLittleEndian!int(0); // horizontal resolution
        bmpBuffer[42 .. 46] = nativeToLittleEndian!int(0); // vertical resolution
        bmpBuffer[46 .. 50] = nativeToLittleEndian!uint(0); // colors used
        bmpBuffer[50 .. 54] = nativeToLittleEndian!uint(0); // important colors

        // RGBA -> BGRA
        ubyte* srcRow = cast(ubyte*) surface.pixels;
        size_t srcPitch = surface.getPitch;

        foreach (int y; 0 .. height)
        {
            int dstY = topDown ? y : (height - 1 - y);
            ubyte* dstRow = bmpBuffer.ptr + dataOffset + dstY * bmpStride;
            ubyte* src = srcRow + y * srcPitch;

            foreach (int x; 0 .. width)
            {
                //  RGBA  > BGRA
                dstRow[0] = src[2]; // B
                dstRow[1] = src[1]; // G
                dstRow[2] = src[0]; // R
                dstRow[3] = src[3]; // A
                src += 4;
                dstRow += 4;
            }

            //padding
            if (bmpStride > width * bytesPerPixel)
            {
                dstRow = bmpBuffer.ptr + dataOffset + dstY * bmpStride + width * bytesPerPixel;
                foreach (int i; 0 .. (bmpStride - width * bytesPerPixel))
                {
                    dstRow[i] = 0;
                }
            }
        }

        try
        {
            write(path, bmpBuffer);
        }
        catch (Exception e)
        {
            return ComResult.error("Error saving BMP file: " ~ e.msg);
        }

        return ComResult.success;
    }

}
