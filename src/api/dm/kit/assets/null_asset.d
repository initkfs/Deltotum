module api.dm.kit.assets.null_asset;

import api.dm.kit.assets.asset : Asset;
import api.core.loggers.null_logging : NullLogging;

import api.dm.kit.assets.fonts.font : Font;

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

    override Font newFont(string fontFilePath, size_t size)
    {
        return new Font(logging, null);
    }
}
