module api.dm.back.sdl3.joysticks.sdl_joystick;

import api.dm.back.sdl3.base.sdl_object_wrapper : SdlObjectWrapper;
import api.dm.com.com_result : ComResult;

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

    bool isConnected() => SDL_JoystickConnected(ptr);

    ComResult getId(out SDL_JoystickID newid)
    {
        auto id = SDL_GetJoystickID(ptr);
        if (id == 0)
        {
            return getErrorRes;
        }

        newid = id;
        return ComResult.success;
    }

    ComResult getGUID(SDL_GUID guid)
    {
        guid = SDL_GetJoystickGUID(ptr);
        return ComResult.success;
    }

    string getNameNew()
    {
        import std.string : fromStringz;

        auto namePtr = SDL_GetJoystickName(ptr);
        if (!namePtr)
        {
            return null;
        }

        return namePtr.fromStringz.idup;
    }

    string getPathNew()
    {
        import std.string : fromStringz;

        auto pathPtr = SDL_GetJoystickPath(ptr);
        if (!pathPtr)
        {
            return null;
        }

        return pathPtr.fromStringz.idup;
    }

    ComResult getGUIDStringNew(out string str)
    {
        SDL_GUID guid;
        if (const err = getGUID(guid))
        {
            return err;
        }
        char[64] buff = 0;
        SDL_GUIDToString(guid, buff.ptr, buff.sizeof);
        import std.string : fromStringz;

        str = buff.fromStringz.idup;
        return ComResult.success;
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
