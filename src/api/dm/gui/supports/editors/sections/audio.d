module api.dm.gui.supports.editors.sections.audio;

import api.dm.gui.controls.control : Control;
import api.dm.com.audio.com_audio_mixer : ComAudioMixer;
import api.dm.com.audio.com_audio_clip : ComAudioClip;
import api.math.geom2.rect2 : Rect2d;
import api.dm.kit.graphics.colors.rgba : RGBA;

import std.stdio;

import api.dm.back.sdl3.externs.csdl3;
import api.dm.com.audio.com_audio_mixer;

import core.sync.mutex;
import core.sync.semaphore;
import api.core.utils.structs.rings.ring_buffer : RingBuffer;
import std.math.traits : isPowerOf2;

import api.dm.kit.media.dsp.dsp_processor : DspProcessor;

import std;

/**
 * Authors: initkfs
 */
class Audio : Control
{
    ComAudioClip clip;

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
        enum sampleWindowSize = 2048;
        enum sampleBufferSize = 8192;

        //pow 2 for FFT

        enum sampleBufferHalfSize = sampleBufferSize / 2;

        enum numBands = 10; // Number of frequency bands
        enum double bandWidth = sampleWindowSize / 2 / cast(double) numBands;
    }

    alias Sint16 = short;
    alias Uint8 = ubyte;

    RGBA[numBands] bandColors;

    static shared Mutex sampleBufferMutex;
    static shared Mutex mutexWrite;
    static shared Mutex mutexSwap;

    bool needSwap;

    bool isRedrawLocalBuffer;

    size_t frameCount;

    override void create()
    {
        super.create;

        sampleBufferMutex = new shared Mutex();

        dspProcessor = new typeof(dspProcessor)(sampleBufferMutex, sampleFreq, sampleWindowSize, logging);
        dspProcessor.dspBuffer.lock;

        foreach (ref bandColor; bandColors)
        {
            auto color = RGBA.random.toHSLA;
            color.l = 0.8;
            color.s = 0.6;
            bandColor = color.toRGBA;
        }

        import api.dm.gui.controls.containers.vbox : VBox;
        import api.dm.gui.controls.containers.hbox : HBox;

        auto musicContainer = new HBox;
        addCreate(musicContainer);
        musicContainer.enablePadding;
        musicContainer.isAlignY = true;

        import api.dm.gui.controls.texts.text : Text;

        auto musicFile = new Text("/home/user/sdl-music/rectangle_120sec_1hz.wav");
        musicContainer.addCreate(musicFile);

        import api.dm.gui.controls.switches.buttons.button : Button;

        auto play = new Button("Play");
        play.onAction ~= (ref e) {

            auto path = musicFile.textString;

            if (clip)
            {
                return;
            }

            dspProcessor.unlock;

            clip = media.mixer.newClip(path);
            if (const err = clip.play)
            {
                throw new Exception(err.toString);
            }
        };
        addCreate(play);

        if (const err = media.mixer.mixer.setPostCallback(&typeof(dspProcessor).signal_callback, cast(void*)&dspProcessor
                .dspBuffer))
        {
            throw new Exception(err.toString);
        }

        debug writeln("Main tid ", thisTid);
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

    override void update(double delta)
    {
        super.update(delta);

        if (!clip)
        {
            return;
        }

        dspProcessor.step;

        double[numBands] bands = 0;

        foreach (i, ref double v; bands)
        {
            size_t start = cast(size_t)(i * bandWidth);
            size_t end = cast(size_t)((i + 1) * bandWidth);

            foreach (j; start .. end)
            {
                v += dspProcessor.fftBuffer[j].amp;
            }

            //writeln(i, " ", v, " ", v, " ", bandWidth, " ", start, " ", end);
            v /= bandWidth;
        }

        auto x = 200;
        auto y = 300;
        auto bandW = 30;

        foreach (i; 0 .. numBands)
        {
            auto amp = bands[i];
            auto dBAmp = 20 * log10(amp == 0 ? double.epsilon : amp);

            graphics.changeColor(bandColors[i]);
            scope (exit)
            {
                graphics.restoreColor;
            }
            auto v = dBAmp;
            graphics.fillRect(x, y - v, bandW, v);
            x += bandW;

            //printf("\n");
        }

    }
}
