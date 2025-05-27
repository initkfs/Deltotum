module api.dm.gui.supports.editors.sections.audio;

// dfmt off
version(DmAddon):
// dfmt on

import api.dm.gui.controls.control : Control;
import api.dm.com.audio.com_audio_mixer : ComAudioMixer;
import api.dm.com.audio.com_audio_clip : ComAudioClip;
import api.dm.com.audio.com_audio_chunk : ComAudioChunk;
import api.dm.addon.media.dsp.signals.analog_signal : AnalogSignal;
import api.math.geom2.rect2 : Rect2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.controls.switches.buttons.button : Button;
import api.dm.addon.media.formats.wav.wav_writer : WavWriter;

import std.stdio;

import api.dm.back.sdl3.externs.csdl3;
import api.dm.com.audio.com_audio_mixer;

import core.sync.mutex;
import core.sync.semaphore;
import api.dm.addon.media.dsp.analyzers.analog_signal_analyzer : AnalogSignalAnalyzer;
import std.math.traits : isPowerOf2;

import api.dm.addon.media.dsp.dsp_processor : DspProcessor;
import api.dm.addon.media.dsp.equalizers.band_equalizer : BandEqualizer;
import api.dm.gui.controls.meters.levels.rect_level : RectLevel;
import api.dm.addon.media.dsp.synthesis.signal_synthesis;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.gui.controls.containers.vbox : VBox;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.switches.buttons.button : Button;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.meters.spinners.spinner : Spinner;
import api.dm.gui.controls.meters.scrolls.hscroll : HScroll;
import api.dm.gui.controls.forms.regulates.regulate_text_panel : RegulateTextPanel;
import api.dm.gui.controls.forms.regulates.regulate_text_field : RegulateTextField;

import api.dm.addon.gui.audio.piano : Piano;
import api.dm.addon.gui.audio.pattern_synthesizer;

import api.dm.addon.media.synthesizers.fm_synthesizer : FMSynthesizer;

import Math = api.math;

import std;
import api.dm.addon.media.music_notes;

/**
 * Authors: initkfs
 */
class Audio : Control
{
    ComAudioClip clip;

    BandEqualizer equalizer;
    RectLevel level;

    Piano piano;

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

    DspProcessor!(SignalType, sampleBufferSize * 2, 2) dspProcessor;

    shared static
    {
        enum sampleWindowSize = 4096;
        enum sampleBufferSize = 40960;
    }

    double sampleFreq = 0;

    alias Sint16 = short;
    alias Uint8 = ubyte;

    static shared Mutex sampleBufferMutex;
    static shared Mutex mutexWrite;
    static shared Mutex mutexSwap;

    import api.dm.kit.media.audio.chunks.audio_chunk : AudioChunk;
    import api.math.numericals.interp;

    AudioChunk!short[] chunks;
    FMSynthesizer!short synt;
    FMSynthesizer!short drumSynt;

    AudioChunk!short drumChunk;

    AudioChunk!short[size_t] channels;

    AudioChunk!short testPatternChunk;

    Text drumText;

    PatternSynthesizer!short patternSynt;

    override void create()
    {
        super.create;

        sampleFreq = media.audioOutSpec.freqHz;

        sampleBufferMutex = new shared Mutex();

        dspProcessor = new typeof(dspProcessor)(sampleBufferMutex, new AnalogSignalAnalyzer, sampleFreq, sampleWindowSize, logging);
        dspProcessor.dspBuffer.lock;

        equalizer = new BandEqualizer(sampleWindowSize, sampleFreq, (fftIndex) {
            return dspProcessor.fftBuffer[fftIndex];
        }, 100, 8);

        dspProcessor.onUpdateFTBuffer = () { equalizer.update; };

        auto root = new VBox;
        addCreate(root);

        auto panelRoot = new HBox;
        panelRoot.isAlignY = true;
        root.addCreate(panelRoot);

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

        synt = new FMSynthesizer!short(sampleFreq);

        piano.settings.adsr(synt.adsr);
        piano.settings.amp = 0.3;
        piano.settings.isFcMulFm = true;
        piano.settings.fmIndex = 1;
        piano.settings.noteType = NoteType.note1_4;

        drumSynt = new FMSynthesizer!short(sampleFreq);

        piano.onPianoKey = (key, ref e) {

            auto freq = key.freqHz;

            import api.dm.com.inputs.com_keyboard : ComKeyName;

            if (input.isPressedKey(ComKeyName.key_a))
            {
                piano.settings.noteType = NoteType.note1;
            }
            else if (input.isPressedKey(ComKeyName.key_s))
            {
                piano.settings.noteType = NoteType.note1_2;
            }
            else if (input.isPressedKey(ComKeyName.key_d))
            {
                piano.settings.noteType = NoteType.note1_4;
            }
            else if (input.isPressedKey(ComKeyName.key_f))
            {
                piano.settings.noteType = NoteType.note1_8;
            }
            else if (input.isPressedKey(ComKeyName.key_g))
            {
                piano.settings.noteType = NoteType.note1_16;
            }

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

            //auto newChunk = media.newHeapChunk!short(1000);
            //synt.sound(newChunk.data.buffer[], freq);

            // chunk.play;
            ///dspProcessor.lock;

            auto noteType = piano.settings.noteType;

            synt.adsr = piano.settings.adsr;

            double amp = piano.settings.amp;
            synt.fm = piano.settings.fm;
            synt.index = piano.settings.fmIndex;
            synt.isFcMulFm = piano.settings.isFcMulFm;

            AudioChunk!short noteChunk;

            synt.note(MusicNote(freq, noteType, 120), amp, (data, time) {
                foreach (chunk; chunks)
                {
                    if (chunk.data.buffer.length == data.length)
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
                    noteChunk = media.newHeapChunk!short(time);
                    chunks ~= noteChunk;
                }
                assert(noteChunk.data.buffer.length == data.length);
                noteChunk.data.buffer[] = data;
            });

            // synt.note(MusicNote(freq, NoteType.note1_4), (buff, time) {
            //     if(noteChunk.data.buffer.length != buff.length){
            //         import std.format: format;
            //         throw new Exception(format("Src buffer len: %s, target %s", buff.length, noteChunk.data.buffer.length));
            //     }
            //     noteChunk.data.buffer[] = buff;
            // }, 120, amp);

            // auto writer = new WavWriter;
            // writer.save("/home/user/sdl-music/out.wav", noteChunk.data.buffer, noteChunk
            //         .spec);

            //synt.note(noteChunk.data.buffer, freq, 0, noteChunk.data.durationMs, 0, sampleFreq);

            assert(noteChunk);

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

        if (const err = media.mixer.mixer.setPostCallback(&typeof(dspProcessor)
                .signal_callback, cast(void*)&dspProcessor
                .dspBuffer))
        {
            throw new Exception(err.toString);
        }

        //drumChunk = media.newHeapChunk!short(500);

        //regenDrum;

        // drumBtn.onOldNewValue ~= (oldv, newv) {
        //     if (newv)
        //     {
        //         parseDrum;
        //         drumChunk.loop;
        //     }
        //     else
        //     {
        //         drumChunk.stop;
        //     }
        // };

        auto fmBox = new VBox;
        addCreate(fmBox);

        patternSynt = new PatternSynthesizer!short(sampleFreq);
        fmBox.addCreate(patternSynt);

        //TODO remove
        patternSynt.loadFile = "/home/user/sdl-music/pattern-load.txt";
        patternSynt.saveFile = "/home/user/sdl-music/pattern-save.txt";

        patternSynt.onPattern = (p) {};

        patternSynt.onPlay = (p, amp) {

            synt.fm = p.pattern.fmHz;
            synt.index = p.pattern.fmIndex;
            synt.isFcMulFm = p.pattern.isFcMulFm;

            MusicNote note = MusicNote(p.pattern.freqHz, p.pattern.noteType, 120);

            synt.note(note, amp, (data, time) {
                if (testPatternChunk)
                {
                    if (testPatternChunk.data.buffer.length == data.length)
                    {
                        testPatternChunk.data.buffer[] = data;
                        return;
                    }

                    testPatternChunk.dispose;
                }

                testPatternChunk = media.newHeapChunk!short(time);
                testPatternChunk.data.buffer[] = data;
            });

            testPatternChunk.play;
        };

        patternSynt.onPatterns = (isPlay, patterns, i, amp) {

            if (!isPlay)
            {
                if (auto chunkPtr = i in channels)
                {
                    (*chunkPtr).stop;
                }
                return;
            }

            FMdata[] data;
            foreach (p; patterns)
            {
                data ~= FMdata(p.pattern.freqHz, p.pattern.fmHz, p.pattern.fmIndex, noteTimeMs(120, p
                        .pattern.noteType), p.pattern.isFcMulFm);
            }

            if (data.length == 0)
            {
                return;
            }

            AudioChunk!short chunk;
            if (auto chunkPtr = i in channels)
            {
                chunk = *chunkPtr;
            }

            synt.sequence(data, amp, (time) {
                if (chunk)
                {
                    if (chunk.data.buffer.length == data.length)
                    {
                        return chunk.data.buffer;
                    }
                    else
                    {
                        chunk.dispose;
                    }
                }

                auto newChunk = media.newHeapChunk!short(time);
                channels[i] = newChunk;
                return newChunk.data.buffer;
            });

            channels[i].loop;
        };

        level = new RectLevel((i) {
            if (i < equalizer.bandValues.length)
            {
                return equalizer.bandValues[i] * 2;
            }
            return 0;
        }, () { return 1; });
        level.levels = 100;
        level.rows = 2;

        level.marginTop = 10;

        equalizer.onUpdateIndexFreqStartEnd = (band, startFreq, endFreq) {
            import std.format : format;

            auto label = format("%s\n%s", Math.round(startFreq), Math.round(
                    endFreq));
            level.labels[band].text = label;
        };

        addCreate(level);
    }

    void parseDrum()
    {
        auto text = drumText.text;
        assert(text.length > 0);

        import std.format.read : formattedRead;

        FMdata[] notes;

        foreach (noteData; text.split(";"))
        {
            if (noteData.length == 0)
            {
                continue;
            }

            int noteDur, fc, fm, index;

            try
            {
                formattedRead(noteData, "%d(%d,%d,%d)", noteDur, fc, fm, index);
                NoteType type = cast(NoteType) noteDur;
                auto time = noteTimeMs(120, type);

                notes ~= FMdata(fc, fm, index, time);
            }
            catch (Exception e)
            {
                logger.error(e.toString);
            }
        }

        double amp = 0.5;

        // drumSynt.sequence(notes, (buff, fullTime) {
        //     //TODO reuse;
        //     if (drumChunk)
        //     {
        //         drumChunk.dispose;
        //     }
        //     drumChunk = media.newHeapChunk!short(fullTime);
        //     drumChunk.data.buffer[] = buff;

        //     // auto writer = new WavWriter;
        //     // writer.save("/home/user/sdl-music/out.wav", drumChunk.data.buffer, drumChunk
        //     //     .spec);
        // }, amp);
    }

    void regenDrum()
    {
        // drumSynt.synt.adsr.attack = drumA.value;
        // drumSynt.synt.adsr.decay = drumD.value;
        // drumSynt.synt.adsr.sustain = drumS.value;
        // drumSynt.synt.adsr.release = drumR.value;

        // drumSynt.synt.sound(drumChunk.data.buffer);
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

    // unittest
    // {
    //     import std.math.operations : isClose;

    //     assert(isClose(noteTimeMs(120, NoteType.note1_8), 500));
    //     assert(isClose(noteTimeMs(60, NoteType.note1_16), 125));
    // }

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

    override void dispose()
    {
        super.dispose;
        foreach (chunk; chunks)
        {
            chunk.dispose;
        }

        if (testPatternChunk)
        {
            testPatternChunk.dispose;
        }
    }
}
