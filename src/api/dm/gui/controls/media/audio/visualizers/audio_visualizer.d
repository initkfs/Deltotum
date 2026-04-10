module api.dm.gui.controls.media.audio.visualizers.audio_visualizer;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.controls.control : Control;

import api.dm.kit.media.dsp.equalizers.band_equalizer : BandEqualizer;
import api.dm.gui.controls.meters.levels.rect_fill_level : RectFillLevel;
import api.dm.kit.media.dsp.analog_signals : AnalogSignal;
import core.atomic : atomicLoad, atomicStore;

import Math = api.math;

/**
 * Authors: initkfs
 */
class AudioVisualizer : Control
{
    float sampleFreq = 0;

    BandEqualizer equalizer;
    BandEqualizer delegate(BandEqualizer) onNewBandEqualizer;
    void delegate(BandEqualizer) onConfiguredEqualizer;

    RectFillLevel level;
    RectFillLevel delegate(RectFillLevel) onNewRectLevel;
    void delegate(RectFillLevel) onConfiguredRectLevel;
    void delegate(RectFillLevel) onCreatedRectLavel;

    AnalogSignal[] fftBuffer;

    float smoothFactor = 0.2f;
    size_t numLevels = 10;

    void delegate(AnalogSignal[]) onFftBuffer;

    this()
    {
        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout;
        layout.isAutoResize = true;

    }

    override void create()
    {
        super.create;

        fftBuffer = new AnalogSignal[](media.audio.DspWindowSize / 2);

        auto newEq = newEqualizer;
        equalizer = !onNewBandEqualizer ? newEq : onNewBandEqualizer(newEq);

        equalizer.onUpdateIndexFreqStartEnd = (band, startFreq, endFreq) {
            import std.format : format;
            import Math = api.math;

            auto label = format("%s\n%s", Math.round(startFreq), Math.round(
                    endFreq));
            level.labels[band].text = label;
        };

        if (onConfiguredEqualizer)
        {
            onConfiguredEqualizer(equalizer);
        }

        auto newLevel = newRectLevel;
        level = !onNewRectLevel ? newLevel : onNewRectLevel(newLevel);
        level.levels = numLevels;

        if (onConfiguredRectLevel)
        {
            onConfiguredRectLevel(level);
        }

        addCreate(level);

        if (onCreatedRectLavel)
        {
            onCreatedRectLavel(level);
        }
    }

    BandEqualizer newEqualizer()
    {
        //TargetSec = Tstart + Pa_GetStreamTime + Pa_GetStreamOutputLatency
        auto equalizer = new BandEqualizer(media.audio.DspWindowSize, media.audio.SAMPLE_RATE, (
                fftIndex) { return fftBuffer[fftIndex]; }, numLevels);
        return equalizer;
    }

    RectFillLevel newRectLevel()
    {
        assert(equalizer);
        auto level = new RectFillLevel((i) {
            if (i < equalizer.bandValues.length)
            {
                return equalizer.bandValues[i];
            }
            return 0;
        }, () { return 1; });
        return level;
    }

    size_t readCount;
    bool isStartRead;

    double fftTimeSec() => (readCount * media.audio.DspWindowSize) / media.audioOutSpec.freqHz;
    double audioTimeSec() => media.audio.buffer.streamTimeSec - atomicLoad(
        media.audio.bufferStartTimeSec);
    //- media.audio.buffer.streamLatencySec;

    double lastUpdateMs = 0;

    override void update(float dt)
    {
        // super.update(dt);

        auto now = platform.timer.ticksMs;
        auto elapsed = now - lastUpdateMs;

        if (elapsed >= media.audio.CallbackIntervalMs)
        {
            auto readSize = media.audio.dspProcessor.fftQueue.read(fftBuffer);
            if (readSize > 0)
            {
                readCount++;

                if (onFftBuffer)
                {
                    onFftBuffer(fftBuffer);
                }
            }
        }
        else
        {
            foreach (ref v; fftBuffer)
            {
                v.magn *= 0.9;
            }
        }

        // if (!isStartRead)
        // {
        //     auto readSize = media.audio.dspProcessor.fftQueue.read(fftBuffer);
        //     if (readSize > 0)
        //     {
        //         isStartRead = true;
        //         readCount++;
        //     }
        // }

        // if (!isStartRead)
        // {
        //     return;
        // }

        // double fftSec = fftTimeSec;
        // double audioSec = audioTimeSec;

        // enum allowDt = 0.02;

        // if (fftSec < audioSec)
        // {
        //     float needOffsetSec = audioSec - fftSec;
        //     if (needOffsetSec > allowDt)
        //     {
        //         size_t needReadSkip = cast(size_t) Math.round(
        //             (needOffsetSec * media.audioOutSpec.freqHz) / media.audio.DspWindowSize);

        //         size_t dropFrames;
        //         enum maxDrop = 5;
        //         foreach (i; 0 .. needReadSkip)
        //         {
        //             auto readSize = media.audio.dspProcessor.fftQueue.read(fftBuffer);
        //             if (readSize > 0)
        //             {
        //                 readCount++;
        //                 dropFrames++;
        //             }
        //             else
        //             {
        //                 //fftBuffer[] = 0;
        //                 //break;
        //             }
        //         }

        //         if (dropFrames >= maxDrop)
        //         {
        //             import std.stdio : writeln;

        //             writeln("Warn. FFT drop sync frames: ", dropFrames);
        //         }

        //         // import std;

        //         // writeln("Drop fft ", fftTimeSec, " ", audioTimeSec, " dt:", audioTimeSec - fftTimeSec, " drop: ", dropFrames);
        //     }

        // }
        // else
        // {
        //     auto dtf = fftSec - audioSec;
        //     enum fftDtSec = 0.5;
        //     if (dtf < fftDtSec)
        //     {
        //         auto readSize = media.audio.dspProcessor.fftQueue.read(fftBuffer);
        //         if (readSize > 0)
        //         {
        //             readCount++;
        //         }
        //     }
        //     else
        //     {
        //         foreach (ref v; fftBuffer)
        //         {
        //             //Value = Value * pow(DecayBase, DeltaTime * 60)
        //             //0.85–0.90
        //             auto newv = v.magn * 0.98;
        //             v.magn = newv;
        //         }
        //     }

        //     // import std;

        //     // writeln(dtf);

        // }

        equalizer.update;
    }
}
