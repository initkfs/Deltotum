module api.dm.com.audio.com_audio_clip;

import api.dm.com.platforms.results.com_result : ComResult;

/**
 * Authors: initkfs
 */
interface ComAudioClip
{
nothrow:

    ComResult getType(out string type);
    ComResult getLoopStartTimeMs(out double timeMs);
    ComResult getLoopEndTimeMs(out double timeMs);
    ComResult getDurationTimeMs(out double timeMs);
    ComResult getPosTimeMs(out double timeMs);
    ComResult getTitleTag(out string title);
    ComResult getTitle(out string title);
    ComResult getVolume(out double value);
    ComResult play(int loops = -1);
}
