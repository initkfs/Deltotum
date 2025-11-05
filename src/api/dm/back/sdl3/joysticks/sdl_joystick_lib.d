module api.dm.back.sdl3.joysticks.sdl_joystick_lib;

import api.dm.com.com_result : ComResult;
import api.dm.back.sdl3.base.sdl_object : SdlObject;
import api.dm.back.sdl3.joysticks.sdl_joystick : SdlJoystick;

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

    bool hasJoystick() => SDL_HasJoystick();
    bool isEventsEnabled() => SDL_JoystickEventsEnabled();

    void setEventsEnabled(bool value)
    {
        SDL_SetJoystickEventsEnabled(value);
    }

    void update()
    {
        SDL_UpdateJoysticks();
    }

    int joystickCount()
    {
        int joystickNums;
        SDL_JoystickID* joysticks = SDL_GetJoysticks(&joystickNums);
        if (joysticks)
        {
            SDL_free(joysticks);
        }
        return joystickNums;
    }

    SdlJoystick joystickByIndex(size_t index)
    {
        int joystickNums;
        SDL_JoystickID* joysticks = SDL_GetJoysticks(&joystickNums);
        if (!joysticks)
        {
            return null;
        }

        scope (exit)
        {
            SDL_free(joysticks);
        }

        if (joystickNums == 0 || index >= joystickNums)
        {
            return null;
        }

        auto joyId = joysticks[0 .. joystickNums][index];
        SDL_Joystick* jPtr = SDL_OpenJoystick(joyId);
        if (jPtr)
        {
            return new SdlJoystick(jPtr);
        }
        return null;
    }

    SdlJoystick firstJoystick()
    {
        SdlJoystick result;
        onJoysticks((ji, joystick) { result = joystick; return false; });
        return result;
    }

    SdlJoystick[] joysticks()
    {
        SdlJoystick[] result;

        onJoysticks((ji, j) { result ~= j; return true; });

        return result;
    }

    void onJoysticks(scope bool delegate(size_t, SdlJoystick) onJoyIndexIsContinue)
    {
        int joystickNums;
        SDL_JoystickID* joysticks = SDL_GetJoysticks(&joystickNums);
        if (!joysticks)
        {
            return;
        }

        scope (exit)
        {
            SDL_free(joysticks);
        }

        if (joystickNums == 0)
        {
            return;
        }

        foreach (ji, jid; joysticks[0 .. joystickNums])
        {
            SDL_Joystick* jPtr = SDL_OpenJoystick(jid);
            if (jPtr)
            {
                if (!onJoyIndexIsContinue(ji, new SdlJoystick(jPtr)))
                {
                    break;
                }
            }
        }
    }

    void quit() nothrow
    {

    }
}
