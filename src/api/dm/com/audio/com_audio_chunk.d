module api.dm.com.audio.com_audio_chunk;

import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.com.destroyable : Destroyable;

/**
 * Authors: initkfs
 */
interface ComAudioChunk : Destroyable
{
nothrow:

    ubyte[] buffer();
}
