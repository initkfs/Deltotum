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

    ComResult play(int loops, int ticks);
    ComResult playFadeIn(int ms = 10, int loops = 0, int ticks = -1);
    
    int lastChannel() nothrow;
}
