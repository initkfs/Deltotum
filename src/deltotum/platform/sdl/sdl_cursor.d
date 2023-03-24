module deltotum.platform.sdl.sdl_cursor;

// dfmt off
version(SdlBackend):
// dfmt on

import deltotum.platform.sdl.base.sdl_object_wrapper : SdlObjectWrapper;

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
