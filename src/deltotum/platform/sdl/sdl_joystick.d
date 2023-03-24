module deltotum.platform.sdl.sdl_joystick;

// dfmt off
version(SdlBackend):
// dfmt on

import deltotum.platform.sdl.base.sdl_object_wrapper : SdlObjectWrapper;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlJoystick : SdlObjectWrapper!SDL_Joystick
{
    this(SDL_Joystick* ptr)
    {
        super(ptr);
    }

    this(int deviceIndex = 0)
    {
        super();
        ptr = SDL_JoystickOpen(deviceIndex);
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

    static SdlJoystick fromDevices()
    {
        const int joystickCount = SDL_NumJoysticks();
        if (joystickCount == 0)
        {
            return null;
        }

        if (joystickCount > 1)
        {
            //TODO index devices
            return null;
        }

        return new SdlJoystick(0);
    }

    override protected bool destroyPtr() @nogc nothrow
    {
        if (ptr)
        {
            SDL_JoystickClose(ptr);
            return true;
        }
        return false;
    }
}
