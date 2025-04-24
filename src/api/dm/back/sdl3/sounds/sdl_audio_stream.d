module api.dm.back.sdl3.sounds.sdl_audio_stream;

import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.com.audio.com_audio_stream : ComAudioStream;
import api.dm.com.audio.com_audio_device : ComAudioSpec, ComAudioDeviceId;
import SdlAudioTypes = api.dm.back.sdl3.sounds.sdl_audio_types;
import api.dm.back.sdl3.base.sdl_object_wrapper : SdlObjectWrapper;

import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */
class SdlAudioStream : SdlObjectWrapper!SDL_AudioStream, ComAudioStream
{

    this(ComAudioSpec src, ComAudioSpec dest)
    {
        SDL_AudioSpec srcSpec = SdlAudioTypes.toSdlSpec(src);
        SDL_AudioSpec destSpec = SdlAudioTypes.toSdlSpec(dest);

        ptr = SDL_CreateAudioStream(&srcSpec, &destSpec);
        if (!ptr)
        {
            throw new Exception("Error creating stream" ~ getError);
        }
    }

    ComResult bind(ComAudioDeviceId id)
    {
        if (!SDL_BindAudioStream(id, ptr))
        {
            return getErrorRes("Error binding stream");
        }
        return ComResult.success;
    }

    ComResult unbind()
    {
        SDL_UnbindAudioStream(ptr);
        return ComResult.success;
    }

    ComResult flush()
    {
        if (!SDL_FlushAudioStream(ptr))
        {
            return getErrorRes("Error flush stream");
        }
        return ComResult.success;
    }

    ComResult clear()
    {
        if (!SDL_ClearAudioStream(ptr))
        {
            return getErrorRes("Error clear stream");
        }
        return ComResult.success;
    }

    ComResult lock()
    {
        if (!SDL_LockAudioStream(ptr))
        {
            return getErrorRes("Cannot lock stream");
        }
        return ComResult.success;
    }

    ComResult unlock()
    {
        if (!SDL_UnlockAudioStream(ptr))
        {
            return getErrorRes("Cannot unlock stream");
        }
        return ComResult.success;
    }

    ComResult putData(void* buf, int len)
    {
        if (!SDL_PutAudioStreamData(ptr, buf, len))
        {
            return getErrorRes("Error sending data to stream");
        }
        return ComResult.success;
    }

    override protected bool disposePtr() nothrow
    {
        if (!ptr)
        {
            return false;
        }
        SDL_DestroyAudioStream(ptr);
        return true;
    }

}
