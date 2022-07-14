module deltotum.hal.sdl.ttf.sdl_ttf_font;

import deltotum.hal.sdl.ttf.base.sdl_ttf_object : SdlTTFObject;

import bindbc.sdl;

import std.string : toStringz;

/**
 * Authors: initkfs
 */
class SdlTTFFont : SdlTTFObject
{
    private
    {
        TTF_Font* ptr;
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

    TTF_Font* getStruct()
    {
        return ptr;
    }

    void destroy()
    {
        TTF_CloseFont(ptr);
    }

}
