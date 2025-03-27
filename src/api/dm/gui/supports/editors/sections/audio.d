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

import Math = api.math;

import std;

/**
 * Authors: initkfs
 */
class Audio : Control
{
    ComAudioClip clip;

    BandEqualizer equalizer;
    RectLevel level;

    this()
    {
        import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

        layout = new HLayout;
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

    bool needSwap;

    bool isRedrawLocalBuffer;

    size_t frameCount;

    double magn1 = 0;

    override void create()
    {
        super.create;

        sampleBufferMutex = new shared Mutex();

        dspProcessor = new typeof(dspProcessor)(sampleBufferMutex, new AnalogSignalAnalyzer, sampleFreq, sampleWindowSize, logging);
        dspProcessor.dspBuffer.lock;

        equalizer = new BandEqualizer(sampleWindowSize, (fftIndex) {
            return dspProcessor.fftBuffer[fftIndex];
        }, 50);

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

        equalizer.onUpdateEnd = () {};

        equalizer.onUpdateStart = () {};

        equalizer.onUpdate = (signal) {};

        dspProcessor.onUpdateFTBuffer = () { equalizer.update; };

        import api.dm.gui.controls.containers.vbox : VBox;
        import api.dm.gui.controls.containers.hbox : HBox;

        auto musicContainer = new HBox;
        addCreate(musicContainer);
        musicContainer.enablePadding;
        musicContainer.isAlignY = true;

        import api.dm.gui.controls.texts.text : Text;

        // auto musicFile = new Text(
        //     "/home/user/sdl-music/November snow.mp3");
        // musicContainer.addCreate(musicFile);

        import api.dm.gui.controls.switches.buttons.button : Button;

        auto play = new Button("Play");
        level.onPointerPress ~= (ref e) {

            if (const err = media.mixer.mixer.setPostCallback(&typeof(dspProcessor)
                    .signal_callback, cast(void*)&dspProcessor
                    .dspBuffer))
            {
                throw new Exception(err.toString);
            }

            dspProcessor.unlock;

            playSound;

            // auto path = musicFile.textString;

            // if (clip)
            // {
            //     return;
            // }

            // clip = media.mixer.newClip(path);
            // if (const err = clip.play)
            // {
            //     throw new Exception(err.toString);
            // }
        };

        //addCreate(play);

    }

    void playSound()
    {
        enum DURATION = 2;
        enum SAMPLE_RATE = 44100.0;

        import api.dm.back.sdl3.mixer.sdl_mixer_chunk : SdlMixerChunk;

        size_t buffLen = cast(size_t)(DURATION * SAMPLE_RATE);
        short[] buffer = new short[](buffLen);
        sine(buffer);

        auto chunk = new SdlMixerChunk(cast(ubyte[]) buffer);

        if (const err = chunk.play(1))
        {
            throw new Exception(err.toString);
        }
    }

    void sine(T)(T[] buffer)
    {
        enum SAMPLE_RATE = 44100.0;
        enum FREQUENCY = 440.0; // Частота тона (A4 нота)

        enum AMPLITUDE = 0.5; // Громкость (0.0 - 1.0)

        foreach (i, ref v; buffer)
        {
            double time = i / SAMPLE_RATE;
            double value = Math.sin(2.0 * Math.PI * FREQUENCY * time) * AMPLITUDE;
            v = cast(T)(value * T.max);
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
        if (clip)
        {
            dspProcessor.unlock;
        }
    }

    override void drawContent()
    {
        super.drawContent;
    }

    override void update(double delta)
    {
        super.update(delta);

        if (!clip)
        {
            return;
        }

        dspProcessor.step;
    }
}
