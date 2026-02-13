module api.dm.kit.sprites2d.images.codecs.base_image_codec;

import api.dm.com.graphics.com_image_codec : ComImageCodec;
import api.dm.com.com_result : ComResult;
import api.dm.com.graphics.com_surface : ComSurface;

import core.stdc.stdlib : malloc, free;

abstract class BaseImageCodec : ComImageCodec
{
    alias load = ComImageCodec.load;

    ComResult load(string path, ComSurface surface) nothrow
    {
        import std.file : read, getSize;
        import std.stdio : File;

        try
        {
            ulong fileSize = path.getSize;
            if (fileSize == 0)
            {
                return ComResult.error("File size must not be 0");
            }

            ubyte* buffPtr = cast(ubyte*) malloc(fileSize);
            if (!buffPtr)
            {
                return ComResult.error("Error allocate file buffer");
            }

            ubyte[] buff = buffPtr[0 .. fileSize];
            scope (exit)
            {
                free(buffPtr);
            }

            File file = File(path, "rb");

            buff = file.rawRead(buff[0 .. fileSize]);
            if (!isSupport(buff))
            {
                return ComResult.error("Not a JPEG file");
            }
            return load(buff, surface);
        }
        catch (Exception e)
        {
            return ComResult.error(e.msg);
        }
    }

    ComResult saveToFile(string path, const(ubyte[]) buff) nothrow
    {
        import std.stdio : File;

        try
        {
            auto f = File(path, "w");
            f.rawWrite(buff);
        }
        catch (Exception e)
        {
            return ComResult.error(e.msg);
        }

        return ComResult.success;
    }

    bool isSupportedExt(string path, string ext) nothrow
    {
        if (ext.length == 0 || ext.length > path.length)
        {
            return false;
        }
        size_t endPos = path.length - ext.length;

        return path[endPos .. $] == ext;
    }
}
