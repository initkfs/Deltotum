module api.dm.gui.supports.demos.sections.media;

import api.dm.kit.media.audio.chunks.audio_chunk : AudioChunk;

import api.dm.gui.controls.control : Control;

import api.dm.kit.media.dsp.analog_signals : AnalogSignal;
import api.dm.kit.media.audio.mixers.mix_sound : MixSound;
import api.dm.kit.media.audio.music.music_notes;

import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.controls.switches.buttons.button : Button;

import core.sync.mutex;

import api.dm.kit.media.dsp.equalizers.band_equalizer : BandEqualizer;
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
import api.dm.gui.controls.media.audio.piano : Piano;
import api.dm.kit.media.audio.synthesizers.fm_synthesizer : FMSynthesizer;
import api.dm.kit.media.audio.mixers.mix_sound : MixSound, SoundHandle;
import api.dm.gui.controls.media.audio.visualizers.audio_visualizer : AudioVisualizer;

import Math = api.math;
import api.math.geom2.rect2 : Rect2f;

/**
 * Authors: initkfs
 */
class Media : Control
{
    Piano piano;
    AudioVisualizer audioLevel;

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

    float sampleFreq = 0;

    FMSynthesizer synt;

    override void create()
    {
        super.create;

        sampleFreq = media.audioOutSpec.freqHz;

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

            synt.isADSR = piano.settings.isADSR;
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

        audioLevel = new AudioVisualizer;
        audioLevel.numLevels = 50;
        root.addCreate(audioLevel);
    }

    override void update(float delta)
    {
        super.update(delta);
    }

    override void dispose()
    {
        super.dispose;
    }
}
