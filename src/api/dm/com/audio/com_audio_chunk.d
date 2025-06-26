module api.dm.com.audio.com_audio_chunk;

import api.dm.com.com_result : ComResult;
import api.dm.com.com_destroyable : ComDestroyable;

/**
 * Authors: initkfs
 */
interface ComAudioChunk : ComDestroyable
{
nothrow:

    ubyte[] buffer();

    ComResult play(int loops, int ticks);
    ComResult stop();
    ComResult playFadeIn(int ms = 10, int loops = 0, int ticks = -1);
    
    int lastChannel() nothrow;
}
