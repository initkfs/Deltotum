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

    RingBuffer!(short, sampleBufferSize) dspBuffer;

    shared static
    {
        enum double sampleFreq = 44100;
        enum sampleBufferStep = 2048;
        enum sampleBufferSize = 8192;

        //pow 2 for FFT

        enum sampleBufferHalfSize = sampleBufferSize / 2;

        enum numBands = 10; // Number of frequency bands
        enum double bandWidth = sampleBufferStep / 2 / cast(double) numBands;

        short[sampleBufferSize] sampleBuffer;
        size_t sampleWriteIndex = 0;
        bool isSampleBufferFull;
    }

    struct SignalData
    {
        double freq = 0;
        double amp = 0;
    }

    short[sampleBufferSize] localSampleBuffer;
    size_t localSampleWriteIndex = 0;

    SignalData[sampleBufferHalfSize] fftBuffer;

    alias Sint16 = short;
    alias Uint8 = ubyte;

    RGBA[numBands] bandColors;

    static shared Mutex sampleBufferMutex;
    static shared Mutex mutexWrite;
    static shared Mutex mutexSwap;

    bool needSwap;

    bool isRedrawLocalBuffer;

    static extern (C) void audio_callback(void* userdata, ubyte* stream, int len) nothrow @nogc
    {
        //debug writeln(len);

        if (len == 0)
        {
            return;
        }

        auto dspBuffer = cast(RingBuffer!(short, sampleBufferSize)*) userdata;
        assert(dspBuffer);

        short[] streamSlice = cast(short[]) stream[0 .. len];
        try
        {
            const writeRes = dspBuffer.writeIfNoLockedSync(streamSlice);
            if (!writeRes)
            {
                debug writefln("Warn, audiobuffer data loss: %s, reason: %s", len, writeRes);
            }
            else
            {
                // debug writefln("Write %s data to buffer, ri %s, wi %s, size: %s, result %s", len, dspBuffer.readIndex, dspBuffer
                //         .writeIndex, dspBuffer.size, writeRes);
            }
        }
        catch (Exception e)
        {
            import std.stdio : stderr;

            debug stderr.writeln("Exception from audio thread: ", e.msg);
            //throw new Error("Exception from audio thread", e);
        }
    }

    size_t frameCount;

    override void create()
    {
        super.create;

        sampleBufferMutex = new shared Mutex();

        dspBuffer = RingBuffer!(short, sampleBufferSize)(sampleBufferMutex);
        dspBuffer.lock;

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

            dspBuffer.unlock;

            clip = media.mixer.newClip(path);
            if (const err = clip.play)
            {
                throw new Exception(err.toString);
            }
        };
        addCreate(play);

        if (const err = media.mixer.mixer.setPostCallback(&audio_callback, cast(void*)&dspBuffer))
        {
            throw new Exception(err.toString);
        }

        debug writeln("Main tid ", thisTid);
    }

    override void pause()
    {
        super.pause;
        dspBuffer.lockSync;
    }

    override void run()
    {
        super.run;
        if (clip)
        {
            dspBuffer.unlock;
        }
    }

    override void update(double delta)
    {
        super.update(delta);

        if (!clip)
        {
            return;
        }

        const readDspRes = dspBuffer.readSync(localSampleBuffer[], sampleBufferStep);

        if (readDspRes)
        {
            // debug writefln("Receive data from buffer, ri %s, wi %s, size: %s", dspBuffer.readIndex, dspBuffer
            //         .writeIndex, dspBuffer.size);
            //S16
            short[] data = cast(short[]) localSampleBuffer[0 .. sampleBufferStep];
            apply_hann_window(data);

            //auto complexData = data.map(v => complex(cast(double) v, 0)).array;

            auto fftRes = fft(data);

            const fftResLen = fftRes.length;

            foreach (i; 0 .. sampleBufferStep / 2)
            {
                auto fftVal = fftRes[i];
                double magnitude = sqrt(fftVal.re * fftVal.re + fftVal.im * fftVal.im);
                //magnitude = magnitued / (sampleBufferStep / 2)
                double freq = i * (sampleFreq / fftResLen);
                fftBuffer[i] = SignalData(freq, magnitude);
            }
        }
        else
        {
            if (!readDspRes.isNoFilled && !readDspRes.isLocked && !readDspRes.isEmpty)
            {
                logger.warning("Warn. Cannot read from dsp buffer, reason: ", readDspRes);
            }
        }

        double[numBands] bands = 0;

        foreach (i, ref double v; bands)
        {
            size_t start = cast(size_t)(i * bandWidth);
            size_t end = cast(size_t)((i + 1) * bandWidth);

            foreach (j; start .. end)
            {
                v += fftBuffer[j].amp;
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

    uint prevPower2(uint x)
    {
        x = x | (x >> 1);
        x = x | (x >> 2);
        x = x | (x >> 4);
        x = x | (x >> 8);
        x = x | (x >> 16);
        return x - (x >> 1);
    }

    //https://stackoverflow.com/questions/364985/algorithm-for-finding-the-smallest-power-of-two-thats-greater-or-equal-to-a-giv
    int pow2roundup(int x)
    {
        if (x < 0)
            return 0;
        --x;
        x |= x >> 1;
        x |= x >> 2;
        x |= x >> 4;
        x |= x >> 8;
        x |= x >> 16;
        return x + 1;
    }

    void apply_hann_window(short[] data)
    {
        import Math = std.math;

        auto size = data.length;
        foreach (i, v; data)
        {
            double window_value = 0.5 * (1 - Math.cos(2 * Math.PI * i / (size - 1)));
            data[i] = cast(short)(data[i] * window_value);
        }
    }
}
