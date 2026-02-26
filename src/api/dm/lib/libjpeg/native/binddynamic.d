module api.dm.lib.libjpeg.native.binddynamic;

/**
 * Authors: initkfs
 */
import api.core.contexts.libs.dynamics.dynamic_loader : DynamicLoader;
import api.dm.lib.libjpeg.native.types;

import core.stdc.config : c_long, c_ulong;

extern (C) nothrow
{
    tjhandle function() tjInitDecompress;
    int function(tjhandle handle, const ubyte* srcBuf,
        int width, int pitch, int height, int pixelFormat,
        ubyte** jpegBuf, c_ulong* jpegSize,
        int jpegSubsamp, int jpegQual, int flags) tjCompress2;
    c_ulong function(int width, int height, int jpegSubsamp) tjBufSize;
    tjhandle function() tjInitCompress;
    int function(tjhandle handle, const ubyte* jpegBuf, ulong jpegSize,
        int* width, int* height, int* jpegSubsamp, int* jpegColorspace) tjDecompressHeader3;
    int function(tjhandle handle, const ubyte* jpegBuf, ulong jpegSize,
        ubyte* dstBuf, int width, int pitch, int height,
        int pixelFormat, int flags) tjDecompress2;
    int function(tjhandle handle) tjDestroy;
    const(char*) function() tjGetErrorStr2;
    void function(ubyte* buffer) tjFree;
}

class JpegLib : DynamicLoader
{
    protected
    {

    }

    override void bindAll()
    {
        bind(&tjInitDecompress, "tjInitDecompress");
        bind(&tjInitCompress, "tjInitCompress");
        bind(&tjCompress2, "tjCompress2");
        bind(&tjBufSize, "tjBufSize");
        bind(&tjDecompressHeader3, "tjDecompressHeader3");
        bind(&tjDecompress2, "tjDecompress2");
        bind(&tjDestroy, "tjDestroy");
        bind(&tjGetErrorStr2, "tjGetErrorStr2");
        bind(&tjFree, "tjFree");
    }

    version (Windows)
    {
        string[] paths = [
            "libturbojpeg.dll"
        ];
    }
    else version (OSX)
    {
        string[] paths = [
            "libturbojpeg.dylib"
        ];
    }
    else version (Posix)
    {
        string[] paths = [
            "libturbojpeg.so"
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
