module api.dm.gui.supports.editors.sections.audio;

import api.dm.gui.controls.control : Control;
import api.dm.com.audio.com_audio_mixer : ComAudioMixer;
import api.dm.com.audio.com_audio_clip : ComAudioClip;
import api.dm.com.audio.com_audio_chunk : ComAudioChunk;
import api.dm.kit.media.dsp.signals.analog_signal : AnalogSignal;
import api.math.geom2.rect2 : Rect2d;
import api.dm.kit.graphics.colors.rgba : RGBA;

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

import Math = api.math;

import std;
import api.dm.kit.media.synthesis.music_notes;

class PianoKey : Control
{
    bool isBlack;
    string name;
    double freqHz;

    Text nameText;

    RGBA backgroundColor;

    this()
    {
        // import api.dm.kit.sprites2d.layouts.vlayout: VLayout;
        // layout = new VLayout;
        // layout.isAutoResize = true;
    }

    override void create()
    {
        super.create;

        nameText = new Text(name);
        addCreate(nameText);

        setBackgroundColor;
    }

    void setBackgroundColor()
    {
        backgroundColor = !isBlack ? RGBA.white : RGBA.black;
    }

    override void drawContent()
    {
        super.drawContent;
        const bounds = boundsRect;
        nameText.x = bounds.middleX - nameText.halfWidth;
        nameText.y = bounds.bottom - nameText.height;

        //stroke
        graphics.changeColor(RGBA.gray);
        graphics.fillRect(boundsRect);
        graphics.restoreColor;

        const fillBounds = boundsRect.withPadding(2);

        graphics.changeColor(backgroundColor);
        graphics.fillRect(fillBounds);
        graphics.restoreColor;
    }
}

/**
 * Authors: initkfs
 */
class Audio : Control
{
    ComAudioClip clip;

    BandEqualizer equalizer;
    RectLevel level;

    Container pianoContainer;

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

    AudioChunk!short chunk;
    SoundSynthesizer!short synt;

    PianoKey[] pianoKeys;

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

        pianoContainer = new HBox;
        //TODO fix window width
        //pianoContainer.width = window.width == 0 ? 1200 : window.width;
        pianoContainer.width = 1275;
        pianoContainer.height = 200;
        root.addCreate(pianoContainer);

        auto pianoCount = 88; //(3 + 12 * 7 + 1)
        enum whiteKeys = 52;
        enum blackKeys = 36;

        const pianoKeyWidth = Math.trunc(pianoContainer.width / whiteKeys);
        const pianoKeyHeight = pianoContainer.height;

        import std.traits : EnumMembers;

        PianoKey[blackKeys] blackKeysArr;
        size_t blackKeysIndex;

        PianoKey[whiteKeys] whiteKeysArr;
        size_t whiteKeysIndex;

        foreach (noteIndex, noteCode; EnumMembers!Octave)
        {
            auto pkey = new PianoKey;

            pkey.name = noteCode.to!string;

            auto octaveNum = pkey.name[1];
            auto keyNum = pkey.name[0];
            if (octaveNum == '0')
            {
                if (keyNum != 'A' && keyNum != 'B')
                {
                    continue;
                }
            }
            else if (octaveNum == '8')
            {
                if (pkey.name != "C8")
                {
                    //TODO break
                    continue;
                }
            }

            pkey.isBlack = pkey.name.length == 3;
            pkey.freqHz = cast(double) noteCode;
            pkey.isLayoutManaged = false;
            pkey.width = pianoKeyWidth;
            pkey.height = !pkey.isBlack ? pianoKeyHeight : pianoKeyHeight / 2;

            if (!pkey.isBlack)
            {
                whiteKeysArr[whiteKeysIndex] = pkey;
                whiteKeysIndex++;
            }
            else
            {
                blackKeysArr[blackKeysIndex] = pkey;
                blackKeysIndex++;
            }
            pianoKeys ~= pkey;
        }

        if (blackKeysIndex != blackKeys)
        {
            import std.format : format;

            throw new Exception(format("Expected %s black keys, but created %s", blackKeys, blackKeysIndex));
        }

        if (whiteKeysIndex != whiteKeys)
        {
            import std.format : format;

            throw new Exception(format("Expected %s white keys, but created %s", whiteKeys, whiteKeysIndex));
        }

        foreach (wk; whiteKeysArr)
        {
            pianoContainer.addCreate(wk);
        }

        foreach (bk; blackKeysArr)
        {
            pianoContainer.addCreate(bk);
        }

        foreach (ii; 0 .. pianoKeys.length)
            (i) {
            auto key = pianoKeys[i];
            key.onPointerEnter ~= (ref e) {
                //TODO optimization
                if (!key.isBlack)
                {
                    if (isForBlackKey(e.x, e.y))
                    {
                        return;
                    }
                }
                key.backgroundColor = RGBA.lightgrey;
            };
            key.onPointerExit ~= (ref e) { key.setBackgroundColor; };

            key.onPointerPress ~= (ref e) {
                if (!key.isBlack)
                {
                    if (isForBlackKey(e.x, e.y))
                    {
                        return;
                    }
                }
                auto freq = key.freqHz;
                synt.note(chunk.data.buffer, freq, 0, chunk.data.durationMs, 0, sampleFreq);
                chunk.play;
            };

        }(ii);

        level = new RectLevel((i) {
            if (i < equalizer.bandValues.length)
            {
                return equalizer.bandValues[i] * 2;
            }
            return 0;
        }, () { return 1; });
        level.levels = 50;

        equalizer.onUpdateIndexFreqStartEnd = (band, startFreq, endFreq) {
            import std.format : format;

            auto label = format("%s\n%s", Math.round(startFreq), Math.round(endFreq));
            level.labels[band].text = label;
        };

        addCreate(level);

        synt = new SoundSynthesizer!short;

        double noteTimeMs(double bpm, NoteType noteType, double minDurMs = 50)
        {
            auto dur = (60.0 / bpm) * (4.0 / noteType) * 1000;
            if (dur < minDurMs)
            {
                dur = minDurMs;
            }
            return dur;
        }

        chunk = media.newHeapChunk!short(noteTimeMs(120, NoteType.note1_4));

        // auto sineBtn = new Button("Play");
        // musicContainer.addCreate(sineBtn);
        // sineBtn.onPointerPress ~= (ref e) {
        //     dspProcessor.unlock;

        //     if (chunk)
        //     {
        //         chunk.dispose;
        //     }

        // import api.dm.kit.media.music.genres.ambient;
        // import api.dm.kit.media.synthesis.chord_synthesis;
        // import api.dm.kit.media.synthesis.music_notes;

        // MusicNote[] notes = [
        //     {Note.C4}, {Note.C4}, {Note.D4}, {Note.C4}, {Note.F4}, {Note.E4},
        //     {Note.C4}, {Note.C4}, {Note.D4}, {Note.C4}, {Note.G4}, {Note.F4},
        // ];
        // synt.sequence(notes, 44100, (short[] buff, double time) {
        //     chunk = media.newHeapChunk!short(time);
        //     chunk.data.buffer[] = buff;
        // }, 120, 2);

        // chunk.play;

        // chunk = media.newHeapChunk!short(200);
        // chunk.onBuffer((data, spec) { chord(data,  spec.freqHz, 1); });

        //     import api.dm.kit.media.dsp.formats.wav_writer: WavWriter;

        //     auto writer = new WavWriter;
        //     writer.save("/home/user/sdl-music/out.wav", chunk.data.buffer, chunk.spec);

        //     // chunk.play;
        //     ///dspProcessor.lock;
        // };

        if (const err = media.mixer.mixer.setPostCallback(&typeof(dspProcessor)
                .signal_callback, cast(void*)&dspProcessor
                .dspBuffer))
        {
            throw new Exception(err.toString);
        }
    }

    protected bool isForBlackKey(double x, double y)
    {
        foreach (PianoKey key; pianoKeys)
        {
            if (!key.isBlack)
            {
                continue;
            }
            if (key.boundsRect.contains(x, y))
            {
                return true;
            }
        }
        return false;
    }

    override void drawContent()
    {
        super.drawContent;

        if (!pianoContainer)
        {
            return;
        }

        double nextX = pianoContainer.x;
        double nextY = pianoContainer.y;
        foreach (i, PianoKey key; pianoKeys)
        {
            if (key.isBlack)
            {
                key.x = nextX - key.halfWidth;
                key.y = nextY;
                continue;
            }

            key.x = nextX;
            key.y = nextY;

            nextX += key.width;
        }
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

        // if (!clip)
        // {
        //     return;
        // }

        dspProcessor.step;
    }
}
