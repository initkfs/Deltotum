module api.dm.gui.controls.audio.visualizers.audio_visualizer;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.controls.control : Control;

import api.dm.kit.media.dsp.dsp_processor : DspProcessor;
import api.dm.kit.media.dsp.equalizers.band_equalizer : BandEqualizer;
import api.dm.gui.controls.meters.levels.rect_level : RectLevel;
import api.dm.kit.media.dsp.analyzers.analog_signal_analyzer;

import core.sync.mutex : Mutex;

/**
 * Authors: initkfs
 */
class AudioVisualizer(SignalType) : Control
{
    double sampleFreq = 0;

    DspProcessor!(SignalType, sampleBufferSize, 2) dspProcessor;
    shared static
    {
        enum sampleWindowSize = 4096;
        enum sampleBufferSize = 20480;
    }

    private
    {
        shared Mutex sampleBufferMutex;
    }

    BandEqualizer equalizer;
    BandEqualizer delegate(BandEqualizer) onNewBandEqualizer;
    void delegate(BandEqualizer) onConfiguredEqualizer;

    RectLevel level;
    RectLevel delegate(RectLevel) onNewRectLevel;
    void delegate(RectLevel) onConfiguredRectLevel;
    void delegate(RectLevel) onCreatedRectLavel;

    this()
    {
        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout;
        layout.isAutoResize = true;
    }

    override void create()
    {
        super.create;

        sampleFreq = media.audioOutSpec.freqHz;

        sampleBufferMutex = new shared Mutex;

        dspProcessor = new typeof(dspProcessor)(sampleBufferMutex, new AnalogSignalAnalyzer, sampleFreq, sampleWindowSize, logging);
        dspProcessor.dspBuffer.lock;

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

        dspProcessor.onUpdateFTBuffer = () { equalizer.update; };

        auto newLevel = newRectLevel;
        level = !onNewRectLevel ? newLevel : onNewRectLevel(newLevel);
        level.levels = 20;

        if (onConfiguredRectLevel)
        {
            onConfiguredRectLevel(level);
        }

        addCreate(level);

        if (onCreatedRectLavel)
        {
            onCreatedRectLavel(level);
        }

        if (const err = media.mixer.mixer.setPostCallback(&typeof(dspProcessor)
                .signal_callback, cast(void*)&dspProcessor
                .dspBuffer))
        {
            throw new Exception(err.toString);
        }
    }

    BandEqualizer newEqualizer()
    {
        auto equalizer = new BandEqualizer(sampleWindowSize, sampleFreq, (fftIndex) {
            return dspProcessor.fftBuffer[fftIndex];
        }, 20, 1, 10000, 15000);
        return equalizer;
    }

    RectLevel newRectLevel()
    {
        assert(equalizer);
        auto level = new RectLevel((i) {
            if (i < equalizer.bandValues.length)
            {
                return equalizer.bandValues[i] * 2;
            }
            return 0;
        }, () { return 1; });
        return level;
    }

    override void update(double dt)
    {
        super.update(dt);
        dspProcessor.step;
    }

    bool lock()
    {
        dspProcessor.lock;
        return true;
    }

    bool unlock()
    {
        dspProcessor.unlock;
        return true;
    }
}
