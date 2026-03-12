module api.dm.gui.controls.media.audio.patterns.sound_pattern;

import api.dm.kit.media.dsp.synthesis.effect_synthesis: ADSR;
import api.dm.kit.media.audio.music.music_notes: NoteType;

struct SoundPattern
{
    NoteType noteType = NoteType.note1_4;

    float freqHz = 0;
    
    float fmHz = 0;
    float fmIndex = 0;

    ADSR adsr;

    bool isFcMulFm;
}