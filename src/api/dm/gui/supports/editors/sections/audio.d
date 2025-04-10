module api.dm.gui.supports.editors.sections.audio;

import api.dm.gui.controls.control : Control;
import api.dm.com.audio.com_audio_mixer : ComAudioMixer;
import api.dm.com.audio.com_audio_clip : ComAudioClip;
import api.dm.com.audio.com_audio_chunk : ComAudioChunk;
import api.dm.kit.media.dsp.signals.analog_signal : AnalogSignal;
import api.math.geom2.rect2 : Rect2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.controls.switches.buttons.button : Button;

import std.stdio;

import api.dm.back.sdl3.externs.csdl3;
import api.dm.com.audio.com_audio_mixer;

import core.sync.mutex;
import core.sync.semaphore;
import api.dm.kit.media.dsp.analysis.analog_signal_analyzer : AnalogSignalAnalyzer;
import std.math.traits : isPowerOf2;

import api.dm.kit.media.dsp.dsp_processor : DspProcessor;
import api.dm.kit.media.dsp.equalizers.band_equalizer : BandEqualizer;
import api.dm.gui.controls.meters.levels.rect_level : RectLevel;
import api.dm.kit.media.synthesis.signal_synthesis;
import api.dm.kit.media.synthesis.synthesizers.sound_synthesizer;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.gui.controls.containers.vbox : VBox;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.switches.buttons.button : Button;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.selects.spinners.spinner : Spinner;

import api.dm.gui.controls.audio.piano : Piano;

import Math = api.math;

import std;
import api.dm.kit.media.synthesis.music_notes;

/**
 * Authors: initkfs
 */
class Audio : Control
{
    ComAudioClip clip;

    BandEqualizer equalizer;
    RectLevel level;

    Piano piano;

    Spinner!double drumA;
    Spinner!double drumD;
    Spinner!double drumS;
    Spinner!double drumR;

    this()
    {
        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout;
        layout.isAutoResize = true;
        isBackground = false;
        layout.isAlignY = false;
    }

    override void initialize()
    {
        super.initialize;
        enablePadding;
    }

    alias SignalType = short;

    DspProcessor!(SignalType, sampleBufferSize) dspProcessor;

    shared static
    {
        enum double sampleFreq = 44100;
        enum sampleWindowSize = 8192;
        enum sampleBufferSize = 40960;

        //pow 2 for FFT

        enum sampleBufferHalfSize = sampleBufferSize / 2;
    }

    alias Sint16 = short;
    alias Uint8 = ubyte;

    static shared Mutex sampleBufferMutex;
    static shared Mutex mutexWrite;
    static shared Mutex mutexSwap;

    import api.dm.kit.media.dsp.chunks.audio_chunk : AudioChunk;

    AudioChunk!short[] chunks;
    SoundSynthesizer!short synt;

    AudioChunk!short drumChunk;

    override void create()
    {
        super.create;

        sampleBufferMutex = new shared Mutex();

        dspProcessor = new typeof(dspProcessor)(sampleBufferMutex, new AnalogSignalAnalyzer, sampleFreq, sampleWindowSize, logging);
        dspProcessor.dspBuffer.lock;

        equalizer = new BandEqualizer(sampleWindowSize, (fftIndex) {
            return dspProcessor.fftBuffer[fftIndex];
        }, 50);

        dspProcessor.onUpdateFTBuffer = () { equalizer.update; };

        auto root = new VBox;
        addCreate(root);

        auto panelRoot = new HBox;
        panelRoot.isAlignY = true;
        root.addCreate(panelRoot);

        auto drumBtn = new Button("Drum");
        drumBtn.isFixedButton = true;
        panelRoot.addCreate(drumBtn);

        drumA = new Spinner!double(0, 0.1, 0.1);
        panelRoot.addCreate(drumA);
        drumA.value = 0.1;

        drumD = new Spinner!double(0, 0.1, 0.1);
        panelRoot.addCreate(drumD);
        drumD.value = 0.2;

        drumS = new Spinner!double(0, 0.1, 0.1);
        panelRoot.addCreate(drumS);
        drumS.value = 0.7;

        drumR = new Spinner!double(0, 0.1, 0.1);
        panelRoot.addCreate(drumR);
        drumR.value = 0.2;

        piano = new Piano;
        //TODO fix window width
        //pianoContainer.width = window.width == 0 ? 1200 : window.width;
        piano.width = 1275;
        piano.height = 200;
        root.addCreate(piano);

        if (const err = media.mixer.mixer.allocChannels(32))
        {
            throw new Exception(err.toString);
        }

        piano.onPianoKey = (key) {

            auto freq = key.freqHz;

            AudioChunk!short noteChunk;

            if (chunks.length == 0)
            {
                noteChunk = newChunk;
                chunks ~= noteChunk;
            }
            else
            {
                foreach (chunk; chunks)
                {
                    const lastChannel = chunk.lastChannel;
                    if (lastChannel >= 0 && !media.mixer.isPlaying(lastChannel))
                    {
                        noteChunk = chunk;
                        break;
                    }
                }
            }

            if (!noteChunk)
            {
                noteChunk = newChunk;
                chunks ~= noteChunk;
            }

            noteChunk.data.buffer[] = 0;

            // MusicNote[] notes = [
            //     {Octave.C4}, {Octave.C4}, {Octave.D4}, {Octave.C4}, {
            //         Octave.F4},
            //         {Octave.E4},
            //         {Octave.C4}, {Octave.C4}, {Octave.D4
            //     },
            //     {Octave.C4}, {Octave.G4},
            //     {Octave.F4},
            // ];

            // synt.sequence(notes, 44100, (short[] buff, double time) {

            //     auto chunk = media.newHeapChunk!short(time);
            //     chunks ~= chunk;
            //     chunk.data.buffer[] = buff;
            //     chunk.play;

            import api.dm.kit.media.dsp.formats.wav_writer : WavWriter;

            //auto newChunk = media.newHeapChunk!short(1000);

            // synt.note( newChunk.data.buffer[], 4186, 0, 1000, 0, 44100);

            // auto writer = new WavWriter;
            // writer.save("/home/user/sdl-music/out.wav", newChunk.data.buffer, newChunk
            //         .spec);
            // chunk.play;
            ///dspProcessor.lock;

            synt.noteOnce(MusicNote(freq, NoteType.note1_4), 44100, (buff, time) {
                noteChunk.data.buffer[] = buff;
            },);

            //synt.note(noteChunk.data.buffer, freq, 0, noteChunk.data.durationMs, 0, sampleFreq);

            if (noteChunk.lastChannel >= 0)
            {
                media.mixer.mixer.stopChannel(noteChunk.lastChannel);
            }

            if (noteChunk.lastChannel >= 0)
            {
                media.mixer.mixer.fadeOut(noteChunk.lastChannel, 5);
            }

            // context.platformContext.sleep(5);
            // if (const err = noteChunk.comChunk.playFadeIn(400))
            // {
            //     logger.error(err.toString);
            // }

            noteChunk.play;
        };

        level = new RectLevel((i) {
            if (i < equalizer.bandValues.length)
            {
                return equalizer.bandValues[i] * 2;
            }
            return 0;
        }, () { return 1; });
        level.levels = 50;

        level.marginTop = 50;

        equalizer.onUpdateIndexFreqStartEnd = (band, startFreq, endFreq) {
            import std.format : format;

            auto label = format("%s\n%s", Math.round(startFreq), Math.round(
                    endFreq));
            level.labels[band].text = label;
        };

        addCreate(level);

        synt = new SoundSynthesizer!short;

        if (const err = media.mixer.mixer.setPostCallback(&typeof(dspProcessor)
                .signal_callback, cast(void*)&dspProcessor
                .dspBuffer))
        {
            throw new Exception(err.toString);
        }

        drumChunk = media.newHeapChunk!short(500);

        regenDrum;

        drumBtn.onOldNewValue ~= (oldv, newv) {
            if (newv)
            {
                drumChunk.loop;
            }
            else
            {
                drumChunk.stop;
            }
        };

    }

    void regenDrum()
    {
        Drum drum;

        drum.adsr.attack = drumA.value;
        drum.adsr.decay = drumD.value;
        drum.adsr.sustain = drumS.value;
        drum.adsr.release = drumR.value;

        drum.drum(drumChunk.data.buffer, 44100, 0.9);
    }

    AudioChunk!short newChunk()
    {
        return media.newHeapChunk!short(noteTimeMs(120, NoteType.note1_4));
    }

    double noteTimeMs(double bpm, NoteType noteType, double minDurMs = 50)
    {
        auto dur = (60.0 / bpm) * (4.0 / noteType) * 1000;
        if (dur < minDurMs)
        {
            dur = minDurMs;
        }
        return dur;
    }

    override void drawContent()
    {
        super.drawContent;
    }

    override void pause()
    {
        super.pause;
        dspProcessor.lock;
    }

    override void run()
    {
        super.run;
        dspProcessor.unlock;
    }

    override void update(double delta)
    {
        super.update(delta);
        dspProcessor.step;
    }
}
