module dm.back.sdl2.sdl_system;

// dfmt off
version(SdlBackend):
// dfmt on
import dm.back.sdl2.base.sdl_object : SdlObject;
import dm.com.platforms.com_system : ComSystem;
import dm.com.platforms.results.com_result : ComResult;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SDLSystem : SdlObject, ComSystem
{
    ComResult openHyperlink(string link) nothrow
    {
        import std.string : toStringz;

        const zeroOrNegErr = SDL_OpenURL(link.toStringz);
        if (zeroOrNegErr < 0)
        {
            return ComResult.error(getError);
        }
        return ComResult.success;
    }
}