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

import std.math.traits : isPowerOf2;

import std;

class DspArrayBuffer(BufferType, size_t BufferSize)
{
    protected shared
    {
        BufferType[BufferSize] sampleBuffer;
        size_t sampleWriteIndex = 0;
        bool isSampleBufferFull;
    }

    void isFull()
    {

    }

    synchronized void put(ubyte[] stream) @nogc nothrow
    {
        if (isSampleBufferFull)
        {
            return;
        }

        size_t rest = sampleWriteIndex == 0 ? sampleBuffer.length
            : sampleBuffer.length - sampleWriteIndex;
        if (rest > 0)
        {
            rest--;
        }

        if (rest == 0)
        {
            if (!isSampleBufferFull)
            {
                isSampleBufferFull = true;
            }

            return;
        }

        size_t buffLen = stream.length / BufferSize.sizeof;
        size_t lostElems;
        if (buffLen > rest)
        {
            lostElems = buffLen - rest;
            debug writeln("Warn. Dsp buffer lost elements: ", lostElems);
            buffLen = rest;
        }

        short[] buffStream = cast(BufferType[]) stream[0 .. buffLen * short.sizeof];

        size_t endIndex = sampleWriteIndex + buffLen;

        //debug writefln("Write to buffer from %s to %s, mustlen %s, len %s, rest %s", sampleWriteIndex, endIndex, mustBeBuffLen, buffLen, rest);

        sampleBuffer[sampleWriteIndex .. endIndex] = buffStream[0 .. buffLen];
        sampleWriteIndex = endIndex;
    }

    synchronized bool copyTo(BufferType[] outBuffer, size_t sizeStep)
    {
        if (isSampleBufferFull)
        {
            outBuffer[] = sampleBuffer;
            isSampleBufferFull = false;
            sampleWriteIndex = 0;
            return true;
        }

        if (sampleWriteIndex > sizeStep)
        {
            outBuffer[0 .. sizeStep] = sampleBuffer[0 .. sizeStep];

            copy(sampleBuffer[sizeStep .. sampleWriteIndex], sampleBuffer[0 .. (
                    sampleWriteIndex - sizeStep)]);

            import core.atomic : atomicOp;

            atomicOp!"-="(sampleWriteIndex, sizeStep);
            return true;
        }

        return false;
    }
}

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

    shared static
    {
        enum double sampleFreq = 44100;
        enum sampleBufferStep = 2048;
        enum sampleBufferSize = 4096;

        DspArrayBuffer!(short, sampleBufferSize) dspBuffer;

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

        auto dspBuffer = cast(shared DspArrayBuffer!(short, sampleBufferSize)) userdata;
        assert(dspBuffer);

        ubyte[] streamSlice = stream[0 .. len];
        dspBuffer.put(streamSlice);
    }

    size_t frameCount;

    override void create()
    {
        super.create;

        dspBuffer = new DspArrayBuffer!(short, sampleBufferSize);

        sampleBufferMutex = new shared Mutex();

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

        auto musicFile = new Text("/home/user/sdl-music/neocrey - System Shock.mp3");
        musicContainer.addCreate(musicFile);

        import api.dm.gui.controls.switches.buttons.button : Button;

        auto play = new Button("Play");
        play.onAction ~= (ref e) {

            auto path = musicFile.textString;

            if (clip)
            {
                return;
            }

            clip = media.mixer.newClip(path);
            if (const err = clip.play)
            {
                throw new Exception(err.toString);
            }
        };
        addCreate(play);

        assert(dspBuffer);
        if (const err = media.mixer.mixer.setPostCallback(&audio_callback, cast(void*) dspBuffer))
        {
            throw new Exception(err.toString);
        }

        debug writeln("Main tid ", thisTid);
    }

    override void update(double delta)
    {
        super.update(delta);

        if (!clip)
        {
            return;
        }

        if (dspBuffer.copyTo(localSampleBuffer, sampleBufferStep))
        {
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
            isRedrawLocalBuffer = false;
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
