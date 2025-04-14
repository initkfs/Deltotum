module api.dm.kit.media.synthesis.synthesizers.fm_synthesizer;

import api.dm.kit.media.synthesis.synthesizers.sound_synthesizer : SoundSynthesizer;
import api.dm.kit.media.dsp.buffers.finite_signal_buffer;
import api.dm.kit.media.synthesis.music_notes;
import api.dm.kit.media.synthesis.effect_synthesis;
import api.dm.kit.media.synthesis.signal_synthesis;

import Math = api.math;

/**
 * Authors: initkfs
 */
/** 
     * fc = 20...20000Khz, fm = 0.1 * fc.. 10 * fc
     * fm = fc * 15
     *
     * Kick,fc:50–100Hz,fm:50–200Hz,i:5–15
     * Snare,fc:150–300Hz,fm:1–5kHz,i:10–30 + white noize
     * Hi-Hat,fc:200–1000Hz,fm:5–10kHz,i:20–50
     *  
     * flute,fc:500–2000Hz,fm:(0.5–1)*fc,i:1-3
     * oven,fc:200–800Hz,fm:(2-5)*fc,i:5-10
     * bell,fc:500–2000Hz,fm(1.414 (nonint,mult) × fc),i:10-50,
     * Moog,fc:50–150Hz,fm(0.5–2*fc),i:3-8
     * DX7,fc:100–200Hz,fm(3–5*fc),i:10–20

     * quack, 11,69.90, adsr(0,4;0.1,0.6,0.4)
     */
class FMSynthesizer(T) : SoundSynthesizer!T
{
    double fm = 0;
    double index = 0;
    bool isFcMulFm;

    this(double sampleRateHz)
    {
        super(sampleRateHz);
        sampleProvider = (double time, double freq, double phase) {
            
            auto targetFm = fm;
            if(isFcMulFm){
                targetFm = freq * targetFm;
            }
            
            return fmodulator(time, phase, freq, targetFm, index);
        };
    }
}
