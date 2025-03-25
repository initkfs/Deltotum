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
import api.dm.kit.media.dsp.equalizers.rect_equalizer : RectEqualizer;

import std;

/**
 * Authors: initkfs
 */
class Audio : Control
{
    ComAudioClip clip;

    RectEqualizer equalizer1;

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

        equalizer1 = new RectEqualizer(sampleWindowSize, (fftIndex) {
            return dspProcessor.fftBuffer[fftIndex];
        });
        addCreate(equalizer1);

        size_t count;

        equalizer1.onUpdateEnd = () { magn1 /= count; count = 0; };

        equalizer1.onUpdateStart = () { magn1 = 0; count = 0; };

        equalizer1.onUpdate = (signal) {
            auto freq = signal.freqHz;

            if (freq >= 1970 && freq <= 2100)
            {

                magn1 += signal.magn;
                count++;
                // writeln(freq);
            }
        };

        dspProcessor.onUpdateFTBuffer = () { equalizer1.updateBands; };

        import api.dm.gui.controls.containers.vbox : VBox;
        import api.dm.gui.controls.containers.hbox : HBox;

        auto musicContainer = new HBox;
        addCreate(musicContainer);
        musicContainer.enablePadding;
        musicContainer.isAlignY = true;

        import api.dm.gui.controls.texts.text : Text;

        auto musicFile = new Text(
            "");
        musicContainer.addCreate(musicFile);

        import api.dm.gui.controls.switches.buttons.button : Button;

        auto play = new Button("Play");
        play.onAction ~= (ref e) {

            auto path = musicFile.textString;

            if (clip)
            {
                return;
            }

            if (const err = media.mixer.mixer.setPostCallback(&typeof(dspProcessor)
                    .signal_callback, cast(void*)&dspProcessor
                    .dspBuffer))
            {
                throw new Exception(err.toString);
            }

            dspProcessor.unlock;

            clip = media.mixer.newClip(path);
            if (const err = clip.play)
            {
                throw new Exception(err.toString);
            }
        };

        addCreate(play);

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

        graphics.changeColor(RGBA.red);
        scope (exit)
        {
            graphics.restoreColor;
        }

        auto xx = 100;
        auto yy = 400;

        auto level = magn1 * 100;

        graphics.fillRect(xx, yy - level, 20, level);

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
