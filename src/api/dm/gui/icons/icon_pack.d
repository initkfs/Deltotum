module api.dm.gui.icons.icon_pack;

import api.dm.com.graphics.com_font : ComFont;
import api.dm.com.graphics.com_surface : ComSurface;
import api.dm.kit.sprites2d.images.image : Image;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.com.com_result : ComResult;

/**
 * Authors: initkfs
 */
class IconPack
{

    ComFont[] iconFonts;

    ComResult render(dchar code, ComSurface surface, RGBA fg, RGBA bg = RGBA.transparent)
    {
        foreach (ComFont font; iconFonts)
        {
            if (!font.hasChar(code))
            {
                continue;
            }

            dchar[1] codes = [code];
            if (const err = font.render(surface, codes[], fg.r, fg.g, fg.b, fg.aByte, bg.r, bg.g, bg.b, bg
                    .aByte))
            {
                return err;
            }

            return ComResult.success;
        }

        return ComResult.error("Not found");
    }

}
