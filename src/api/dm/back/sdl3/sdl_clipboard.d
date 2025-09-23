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
    string getTextNew() nothrow
    {
        const(char*) text = SDL_GetClipboardText();
        if (!text)
        {
            return null;
        }

        scope (exit)
        {
            freeSdlPtr(cast(void*) text);
        }

        return text.fromStringz.idup;
    }

    bool hasText() nothrow => SDL_HasClipboardText();

    ComResult setText(const(char)[] text) nothrow
    {
        if (!SDL_SetClipboardText(text.toStringz))
        {
            return getErrorRes("Error setting clipboard text");
        }
        return ComResult.success;
    }

    bool hasData(string dataType, out bool isHasData) nothrow => SDL_HasClipboardData(
        dataType.toStringz);

    ComResult getData(string dataType, scope void delegate(void* data, size_t dataLength) nothrow onScopeData) nothrow
    {
        assert(onScopeData);

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

        if (dataLen == 0)
        {
            return getErrorRes("Error getting data from clipboard: data length == 0");
        }

        onScopeData(dataPtr, dataLen);
        return ComResult.success;
    }

    ComResult clearData() nothrow
    {
        if (!SDL_ClearClipboardData)
        {
            return getErrorRes("Error clearing clipboard data");
        }
        return ComResult.success;
    }

    ComResult getPrimarySelectionTextNew(out string newText) nothrow
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

    bool hasPrimarySelectionText(out bool isHasText) nothrow => SDL_HasPrimarySelectionText();

    bool isDisposed() nothrow pure @safe
    {
        return false;
    }

    bool dispose() nothrow
    {
        return false;
    }
}
