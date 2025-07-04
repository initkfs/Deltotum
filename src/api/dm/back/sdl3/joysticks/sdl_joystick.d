module api.dm.back.sdl3.joystick.sdl_joystick;

import api.dm.back.sdl3.base.sdl_object_wrapper : SdlObjectWrapper;

import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */
class SdlJoystick : SdlObjectWrapper!SDL_Joystick
{
    this(SDL_Joystick* ptr)
    {
        super(ptr);
    }

    this(SDL_JoystickID deviceIndex = 0)
    {
        super();
        ptr = SDL_OpenJoystick(deviceIndex);
        if (!ptr)
        {
            string error = "Failed to open joystick";
            if (const err = getError)
            {
                error ~= err;
            }
            throw new Exception(error);
        }
    }

    override protected bool disposePtr() nothrow
    {
        if (ptr)
        {
            SDL_CloseJoystick(ptr);
            return true;
        }
        return false;
    }
}
