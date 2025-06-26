module api.dm.back.sdl3.joystick.sdl_joystick_lib;

import api.dm.com.com_result : ComResult;
import api.dm.back.sdl3.base.sdl_object : SdlObject;
import api.dm.back.sdl3.joystick.sdl_joystick : SdlJoystick;

import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */
class SdlJoystickLib : SdlObject
{
    ComResult initialize() nothrow
    {
        return ComResult.success;
    }

    SdlJoystick currentJoystick()
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

        if (joystickNums == 0)
        {
            return null;
        }

        return new SdlJoystick(*joysticks);
    }

    void quit() nothrow
    {

    }
}
