module api.dm.kit.assets.null_asset;

import api.dm.kit.assets.asset : Asset;
import api.core.loggers.null_logging : NullLogging;

import api.dm.com.graphics.com_font : ComFont;

/**
 * Authors: initkfs
 */
class NullAsset : Asset
{

    this() @safe
    {
        super(new NullLogging, "", () {
            assert(false, "Cannot instantiate null font");
            return null;
        });
    }

    override string imagePath(string imageFile) const
    {
        return null;
    }

    override string fontPath(string fontFile) const
    {
        return null;
    }

    override ComFont newFont(string fontFilePath, uint size)
    {
        import api.dm.com.com_result : ComResult;
        import api.dm.com.graphics.com_surface : ComSurface;

        return new class ComFont
        {
            bool hasChar(ulong code) => false;
            bool dispose() nothrow => false;
            bool isDisposed() => false;

            ComResult render(
                ComSurface targetSurface,
                const(dchar[]) text,
                ubyte fr, ubyte fg, ubyte fb, ubyte fa,
                ubyte br, ubyte bg, ubyte bb, ubyte ba) => ComResult.success;

            ComResult create(string path, uint size) => ComResult.success;
            string getFontPath() => null;
            uint getFontSize() => 0;
            uint getMaxHeight() => 0;
        };
    }
}
