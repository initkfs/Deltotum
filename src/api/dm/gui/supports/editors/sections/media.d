module api.dm.gui.supports.editors.sections.media;

// dfmt off
version(EnableAddon):
// dfmt on

import api.dm.kit.media.audio.chunks.audio_chunk : AudioChunk;

import api.dm.gui.controls.control : Control;

import api.dm.kit.media.dsp.analog_signals : AnalogSignal;
import api.dm.kit.media.dsp.analyzers.analog_signal_analyzer : AnalogSignalAnalyzer;
import api.dm.kit.media.audio.mixers.mix_sound : MixSound;
import api.dm.kit.media.audio.music.music_notes;

import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.controls.switches.buttons.button : Button;

import core.sync.mutex;

import api.dm.kit.media.dsp.dsp_processor : DspProcessor;
import api.dm.kit.media.dsp.equalizers.band_equalizer : BandEqualizer;
import api.dm.gui.controls.meters.levels.rect_level : RectLevel;
import api.dm.kit.media.dsp.synthesis.signal_synthesis;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.gui.controls.containers.vbox : VBox;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.meters.spinners.spinner : Spinner;
import api.dm.gui.controls.meters.scrolls.hscroll : HScroll;
import api.dm.gui.controls.forms.regulates.regulate_text_panel : RegulateTextPanel;
import api.dm.gui.controls.forms.regulates.regulate_text_field : RegulateTextField;
import api.dm.addon.media.audio.gui.piano : Piano;
import api.dm.kit.media.audio.synthesizers.fm_synthesizer : FMSynthesizer;
import api.dm.kit.media.audio.mixers.mix_sound : MixSound, SoundHandle;

import Math = api.math;
import api.math.geom2.rect2 : Rect2f;

/**
 * Authors: initkfs
 */
class Media : Control
{
    BandEqualizer equalizer;
    RectLevel level;
    Piano piano;

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

    alias SignalType = float;

    DspProcessor!(sampleBufferSize * 2, 2) dspProcessor;

    shared static
    {
        enum sampleWindowSize = 4096;
        enum sampleBufferSize = 40960;
    }

    float sampleFreq = 0;

    static shared Mutex sampleBufferMutex;

    import api.dm.kit.media.audio.chunks.audio_chunk : AudioChunk;
    import api.math.numericals.interp;

    FMSynthesizer synt;
    FMSynthesizer drumSynt;

    override void create()
    {
        super.create;

        sampleFreq = media.audioOutSpec.freqHz;

        sampleBufferMutex = new shared Mutex();

        // dspProcessor = new typeof(dspProcessor)(sampleBufferMutex, new AnalogSignalAnalyzer, sampleFreq, sampleWindowSize, logging);
        // dspProcessor.dspBuffer.block;

        // equalizer = new BandEqualizer(sampleWindowSize, sampleFreq, (fftIndex) {
        //     return dspProcessor.fftBuffer[fftIndex];
        // }, 100, 8);

        // dspProcessor.onUpdateFTBuffer = () { equalizer.update; };

        auto root = new VBox;
        addCreate(root);

        auto panelRoot = new HBox;
        panelRoot.isAlignY = true;
        root.addCreate(panelRoot);

        piano = new Piano;

        //TODO fix window width
        //pianoContainer.width = window.width == 0 ? 1200 : window.width;
        piano.width = 1275;
        piano.height = 200;
        root.addCreate(piano);

        synt = new FMSynthesizer(sampleFreq);

        piano.settings.adsr(synt.adsr);
        piano.settings.amp = 0.3;
        piano.settings.isFcMulFm = true;
        piano.settings.fmIndex = 1;
        piano.settings.noteType = NoteType.note1_4;

        drumSynt = new FMSynthesizer(sampleFreq);

        piano.onPianoKey = (key, ref e) {

            auto freq = key.freqHz;

            import api.dm.com.inputs.com_keyboard : ComKeyName;

            if (input.isPressedKey(ComKeyName.key_a))
            {
                piano.settings.noteType = NoteType.note1;
            }
            else if (input.isPressedKey(ComKeyName.key_s))
            {
                piano.settings.noteType = NoteType.note1_2;
            }
            else if (input.isPressedKey(ComKeyName.key_d))
            {
                piano.settings.noteType = NoteType.note1_4;
            }
            else if (input.isPressedKey(ComKeyName.key_f))
            {
                piano.settings.noteType = NoteType.note1_8;
            }
            else if (input.isPressedKey(ComKeyName.key_g))
            {
                piano.settings.noteType = NoteType.note1_16;
            }

            auto noteType = piano.settings.noteType;

            synt.adsr = piano.settings.adsr;

            float amp = piano.settings.amp;
            synt.fm = piano.settings.fm;
            synt.index = piano.settings.fmIndex;
            synt.isFcMulFm = piano.settings.isFcMulFm;

            import core.stdc.stdlib : free;

            AudioChunk* chunk = synt.noteNew(MusicNote(freq, noteType, 120), amp);
            MixSound MixSound = MixSound(chunk.buffer);
            import std.conv: to;
            MixSound.name = freq.to!string;

            MixSound.freeFunPtr = &free;
            if (!media.audio.isRunning)
            {
                media.audio.start;
            }

            media.audio.play(MixSound);
        };

        // level = new RectLevel((i) {
        //     if (i < equalizer.bandValues.length)
        //     {
        //         return equalizer.bandValues[i] * 2;
        //     }
        //     return 0;
        // }, () { return 1; });
        // level.levels = 100;
        // level.rows = 2;

        // level.marginTop = 10;

        // equalizer.onUpdateIndexFreqStartEnd = (band, startFreq, endFreq) {
        //     import std.format : format;

        //     auto label = format("%s\n%s", Math.round(startFreq), Math.round(
        //             endFreq));
        //     level.labels[band].text = label;
        // };

        // addCreate(level);

        // import api.dm.kit.media.engines.media_engine : mediaPlayer;
        // import api.dm.gui.controls.containers.hbox : HBox;

        // auto playerBox = new HBox;
        // playerBox.isAlignY = true;
        // addCreate(playerBox);
    }

    override void pause()
    {
        super.pause;
    }

    override void run()
    {
        super.run;
    }

    override void update(float delta)
    {
        super.update(delta);
    }

    override void dispose()
    {
        super.dispose;
        // foreach (chunk; chunks)
        // {
        //     chunk.dispose;
        // }
    }
}
