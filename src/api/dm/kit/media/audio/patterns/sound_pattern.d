module api.dm.kit.media.audio.patterns.sound_pattern;

import api.dm.kit.media.dsp.synthesis.effect_synthesis: ADSR;
import api.dm.kit.media.audio.music_notes: NoteType;

struct SoundPattern
{
    NoteType noteType = NoteType.note1_4;

    double freqHz = 0;
    
    double fmHz = 0;
    double fmIndex = 0;

    ADSR adsr;

    bool isFcMulFm;
}