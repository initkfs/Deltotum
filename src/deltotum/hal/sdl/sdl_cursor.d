module deltotum.hal.sdl.sdl_cursor;

import deltotum.hal.sdl.base.sdl_object_wrapper : SdlObjectWrapper;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SDLCursor : SdlObjectWrapper!SDL_Cursor
{
    bool isDefault;
    
    this()
    {
        super();
    }

    this(SDL_Cursor* ptr)
    {
        super(ptr);
    }

    override protected bool destroyPtr() @nogc nothrow
    {
        if (ptr)
        {
            SDL_FreeCursor(ptr);
            return true;
        }
        return false;
    }
}
