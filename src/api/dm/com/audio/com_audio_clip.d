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
    ComResult getLoopStartTimeMs(out double timeMs);
    ComResult getLoopEndTimeMs(out double timeMs);
    ComResult getDurationTimeMs(out double timeMs);
    ComResult getPosTimeMs(out double timeMs);
    ComResult getTitleTag(out string title);
    ComResult getTitle(out string title);
    ComResult getVolume(out double value);
    ComResult setVolume(double value);
    ComResult setPos(double value);
    ComResult play(int loops);
    ComResult play();
    ComResult stop();
    ComResult pause();
    ComResult resume();

    bool isPlaying();
}
