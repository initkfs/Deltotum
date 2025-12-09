module api.dm.addon.media.audio.patterns.sound_pattern;

import api.dm.addon.dsp.synthesis.effect_synthesis: ADSR;
import api.dm.addon.media.audio.music_notes: NoteType;

struct SoundPattern
{
    NoteType noteType = NoteType.note1_4;

    float freqHz = 0;
    
    float fmHz = 0;
    float fmIndex = 0;

    ADSR adsr;

    bool isFcMulFm;
}