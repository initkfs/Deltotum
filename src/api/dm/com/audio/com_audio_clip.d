module api.dm.com.audio.com_audio_clip;

import api.dm.com.com_result : ComResult;
import api.dm.com.com_destroyable: ComDestroyable;

/**
 * Authors: initkfs
 */
interface ComAudioClip : ComDestroyable
{
nothrow:

    ComResult create(string path) nothrow;
    ComResult getType(out string type);
    ComResult getLoopStartTimeMs(out float timeMs);
    ComResult getLoopEndTimeMs(out float timeMs);
    ComResult getDurationTimeMs(out float timeMs);
    ComResult getPosTimeMs(out float timeMs);
    ComResult getTitleTag(out string title);
    ComResult getTitle(out string title);
    ComResult getVolume(out float value);
    ComResult setVolume(float value);
    ComResult setPos(float value);
    ComResult play(int loops);
    ComResult play();
    ComResult stop();
    ComResult pause();
    ComResult resume();

    bool isPlaying();
}
