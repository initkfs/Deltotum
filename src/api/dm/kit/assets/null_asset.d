module api.dm.kit.assets.null_asset;

import api.dm.kit.assets.asset : Asset;
import api.core.loggers.null_logging : NullLogging;

import api.dm.com.graphic.com_font : ComFont;

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

    override ComFont newFont(string fontFilePath, size_t size)
    {
        import api.dm.com.com_result : ComResult;
        import api.dm.com.graphic.com_surface : ComSurface;
        import api.dm.com.graphic.com_font: ComFontHinting;

        return new class ComFont
        {
            bool dispose() nothrow => false;
            bool isDisposed() => false;

            ComResult renderFont(
                ComSurface targetSurface,
                const(dchar[]) text,
                ubyte fr, ubyte fg, ubyte fb, ubyte fa,
                ubyte br, ubyte bg, ubyte bb, ubyte ba) => ComResult.success;

            ComResult load(string path, double size) => ComResult.success;
            string getFontPath() => null;
            double getFontSize() => 0;
            double getMaxHeight() => 0;
            ComResult setHinting(ComFontHinting hinting) => ComResult.success;
        };
    }
}
