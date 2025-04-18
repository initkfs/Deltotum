module api.dm.kit.media.audio.music_notes;

import api.dm.kit.media.dsp.synthesis.signal_synthesis;
import api.dm.kit.media.dsp.synthesis.effect_synthesis;

import Math = api.math;

/** 
Authors: initkfs
*/

struct MusicNote
{
    double freqHz = 0;
    double durationMs = 0;

    this(double freqHz, double durMs)
    {
        this.freqHz = freqHz;
        this.durationMs = durMs;
    }

    this(double freqHz, NoteType type, double bpm, double minDurationMs = 10)
    {
        this.freqHz = freqHz;
        this.durationMs = noteTimeMs(bpm, type, minDurationMs);
    }
}

enum NoteType
{
    note1 = 1,
    note1_2 = 2,
    note1_4 = 4,
    note1_8 = 8,
    note1_16 = 16
}

double fromMIDI(int midiNote) => 440.0 * Math.pow(2.0, (midiNote - 69) / 12.0);

double noteTimeMs(double bpm, NoteType noteType, double minDurMs = 50)
{
    const dur = (60.0 / bpm) * (4.0 / noteType) * 1000;
    return dur < minDurMs ? minDurMs : dur;
}

unittest
{
    import std.math.operations : isClose;

    assert(isClose(noteTime(120, NoteType.note1_8), 500));
    assert(isClose(noteTime(60, NoteType.note1_16), 125));
}

enum Octave : double
{
    //do(С) re(D) mi(Е) fa(F) sol(G) la(A) ti(B\H)

    //S == ♯
    //Subcontroctave
    C0 = 16.3516,
    C0s = 17.3239, // C#0/Db0
    D0 = 18.3540,
    D0s = 19.4454, // D#0/Eb0
    E0 = 20.6017,
    F0 = 21.8268,
    F0s = 23.1247, // F#0/Gb0
    G0 = 24.4997,
    G0s = 25.9565, // G#0/Ab0
    A0 = 27.5000,
    A0s = 29.1352, // A#0/Bb0
    B0 = 30.8677,

    //controctave
    C1 = 32.7032,
    C1s = 34.6478,
    D1 = 36.7081,
    D1s = 38.8909,
    E1 = 41.2034,
    F1 = 43.6535,
    F1s = 46.2493,
    G1 = 48.9994,
    G1s = 51.9131,
    A1 = 55.0000,
    A1s = 58.2705,
    B1 = 61.7354,

    //major octave
    C2 = 65.4064,
    C2s = 69.2957,
    D2 = 73.4162,
    D2s = 77.7817,
    E2 = 82.4069,
    F2 = 87.3071,
    F2s = 92.4986,
    G2 = 97.9989,
    G2s = 103.826,
    A2 = 110.000,
    A2s = 116.541,
    B2 = 123.471,

    //minor octave
    C3 = 130.813,
    C3s = 138.591,
    D3 = 146.832,
    D3s = 155.563,
    E3 = 164.814,
    F3 = 174.614,
    F3s = 184.997,
    G3 = 195.998,
    G3s = 207.652,
    A3 = 220.000,
    A3s = 233.082,
    B3 = 246.942,

    //Octave 1
    C4 = 261.626,
    C4s = 277.183,
    D4 = 293.665,
    D4s = 311.127,
    E4 = 329.628,
    F4 = 349.228,
    F4s = 369.994,
    G4 = 391.995,
    G4s = 415.305,
    A4 = 440.000,
    A4s = 466.164,
    B4 = 493.883,

    //Octave 2
    C5 = 523.251,
    C5s = 554.365,
    D5 = 587.330,
    D5s = 622.254,
    E5 = 659.255,
    F5 = 698.456,
    F5s = 739.989,
    G5 = 783.991,
    G5s = 830.609,
    A5 = 880.000,
    A5s = 932.328,
    B5 = 987.767,

    //Octave 3
    C6 = 1046.50,
    C6s = 1108.73,
    D6 = 1174.66,
    D6s = 1244.51,
    E6 = 1318.51,
    F6 = 1396.91,
    F6s = 1479.98,
    G6 = 1567.98,
    G6s = 1661.22,
    A6 = 1760.00,
    A6s = 1864.66,
    B6 = 1975.53,

    //Octave 4
    C7 = 2093.00,
    C7S = 2217.46,
    D7 = 2349.32,
    D7S = 2489.02,
    E7 = 2637.02,
    F7 = 2793.83,
    F7S = 2959.96,
    G7 = 3135.96,
    G7S = 3322.44,
    A7 = 3520.00,
    A7S = 3729.31,
    B7 = 3951.07,

    //Octave 5
    C8 = 4186.01,
    C8s = 4434.92,
    D8 = 4698.64,
    D8s = 4978.03,
    E8 = 5274.04,
    F8 = 5587.65,
    F8s = 5919.91,
    G8 = 6271.93,
    G8s = 6644.88,
    A8 = 7040.00,
    A8s = 7458.62,
    B8 = 7902.13,
}
