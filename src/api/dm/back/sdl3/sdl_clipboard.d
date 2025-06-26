module api.dm.back.sdl3.sdl_clipboard;



import api.dm.com.inputs.com_clipboard : ComClipboard;
import api.dm.back.sdl3.base.sdl_object : SdlObject;
import api.dm.com.com_result : ComResult;

import api.dm.back.sdl3.externs.csdl3;

import std.string : toStringz, fromStringz;

/**
 * Authors: initkfs
 */
class SdlClipboard : SdlObject, ComClipboard
{
    ComResult getText(out string newText) nothrow
    {
        const(char*) text = SDL_GetClipboardText();
        if (!text)
        {
            return getErrorRes("Error getting text from clipboard.");
        }

        scope (exit)
        {
            freeSdlPtr(cast(void*) text);
        }

        newText = text.fromStringz.idup;
        return ComResult.success;
    }

    ComResult hasText(out bool isHasText) nothrow
    {
        if (SDL_HasClipboardText())
        {
            isHasText = true;
        }

        return ComResult.success;
    }

    ComResult setText(const(char)[] text) nothrow
    {
        if (!SDL_SetClipboardText(text.toStringz))
        {
            return getErrorRes("Error setting clipboard text");
        }
        return ComResult.success;
    }

    ComResult hasData(string dataType, out bool isHasData) nothrow
    {
        isHasData = SDL_HasClipboardData(dataType.toStringz);
        return ComResult.success;
    }

    ComResult getData(string dataType, scope void delegate(void* data, size_t dataLength) nothrow onData) nothrow
    {
        assert(onData);

        size_t dataLen;
        void* dataPtr = SDL_GetClipboardData(dataType.toStringz, &dataLen);
        if (!dataPtr)
        {
            return getErrorRes("Error getting data from clipboard");
        }

        scope (exit)
        {
            freeSdlPtr(dataPtr);
        }
        //TODO dataLen == 0?
        onData(dataPtr, dataLen);
        return ComResult.success;
    }

    // ComResult clear()
    // {
    //     if (!SDL_ClearClipboardData)
    //     {
    //         return getErrorRes("Error clearing clipboard");
    //     }
    // }

    ComResult getPrimarySelectionText(out string newText) nothrow
    {
        const(char*) text = SDL_GetPrimarySelectionText();
        if (!text)
        {
            return getErrorRes("Error getting primary selection text from clipboard.");
        }

        scope (exit)
        {
            freeSdlPtr(cast(void*) text);
        }

        newText = text.fromStringz.idup;
        return ComResult.success;
    }

    ComResult setPrimarySelectionText(const(char)[] text) nothrow
    {
        if (!SDL_SetPrimarySelectionText(text.toStringz))
        {
            return getErrorRes("Error setting primary selection text");
        }
        return ComResult.success;
    }

    ComResult hasPrimarySelectionText(out bool isHasText) nothrow
    {
        if (SDL_HasPrimarySelectionText())
        {
            isHasText = true;
        }

        return ComResult.success;
    }

    bool isDisposed() nothrow pure @safe
    {
        return false;
    }

    bool dispose() nothrow
    {
        return false;
    }
}
