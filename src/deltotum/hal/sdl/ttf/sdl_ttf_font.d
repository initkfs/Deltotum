module deltotum.hal.sdl.ttf.sdl_ttf_font;

import deltotum.hal.sdl.base.sdl_object_wrapper : SdlObjectWrapper;
import deltotum.hal.sdl.ttf.base.sdl_ttf_object : SdlTTFObject;

import bindbc.sdl;

import std.string : toStringz;

/**
 * Authors: initkfs
 */
class SdlTTFFont : SdlObjectWrapper!TTF_Font
{
    private
    {
        string path;
        int fontSize;
    }

    this(string fontFilePath, int fontSize = 12)
    {
        this.path = fontFilePath;
        this.fontSize = fontSize;
        ptr = TTF_OpenFont(this.path.toStringz, fontSize);
        if (!ptr)
        {
            //TODO error from sdl?
            string error = "Unable to load ttf font.";
            if (const err = getError)
            {
                error ~= err;
            }
            throw new Exception(error);
        }
    }

    override bool destroyPtr()
    {
        if (ptr)
        {
            TTF_CloseFont(ptr);
            return true;
        }
        return false;
    }

}
