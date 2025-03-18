module api.dm.kit.media.dsp.analysis.spectrum.spectrogram;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;

import api.dm.kit.media.dsp.signals.analog_signal : AnalogSignal;

/**
 * Authors: initkfs
 */
class Spectrogram : Sprite2d
{
    AnalogSignal[] data;

    this(AnalogSignal[] data)
    {
        this.data = data;
    }

}
