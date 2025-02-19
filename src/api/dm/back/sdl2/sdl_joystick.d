module api.dm.back.sdl2.sdl_joystick;

// dfmt off
version(SdlBackend):
// dfmt on

import api.dm.back.sdl2.base.sdl_object_wrapper : SdlObjectWrapper;

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

    static SdlJoystick fromDevices()
    {
        int joystickNums;
        SDL_JoystickID* joysticks = SDL_GetJoysticks(&joystickNums);
        if (!joysticks)
        {
            return null;
        }

        // if (joysticks) {
        //     for (i = 0; i < num_joysticks; ++i) {
        //         SDL_JoystickID instance_id = joysticks[i];
        //         const char *name = SDL_GetJoystickInstanceName(instance_id);
        //         const char *path = SDL_GetJoystickInstancePath(instance_id);

        //         SDL_Log("Joystick %" SDL_PRIu32 ": %s%s%s VID 0x%.4x, PID 0x%.4x\n",
        //                 instance_id, name ? name : "Unknown", path ? ", " : "", path ? path : "", SDL_GetJoystickInstanceVendor(instance_id), SDL_GetJoystickInstanceProduct(instance_id));
        //     }
        //     SDL_free(joysticks);
        // }

        if(joystickNums == 0){
            return null;
        }

        return new SdlJoystick(*joysticks);
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
