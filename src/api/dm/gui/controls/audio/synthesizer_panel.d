module api.dm.gui.controls.audio.synthesizer_panel;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.gui.controls.containers.vbox : VBox;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.switches.checks.check : Check;
import api.dm.gui.controls.switches.base_biswitch : BaseBiswitch;
import api.dm.gui.controls.meters.scrolls.base_regular_mono_scroll : BaseRegularMonoScroll;
import api.dm.gui.controls.meters.scrolls.hscroll : HScroll;
import api.dm.gui.controls.switches.buttons.button : Button;
import api.dm.gui.controls.selects.spinners.spinner : FracSpinner;
import api.dm.gui.controls.selects.choices.choice : Choice;

import api.dm.gui.controls.forms.regulates.regulate_text_panel : RegulateTextPanel;
import api.dm.gui.controls.forms.regulates.regulate_text_field : RegulateTextField;
import api.dm.kit.media.synthesis.sound_pattern : SoundPattern;

import api.dm.kit.media.synthesis.effect_synthesis : ADSR;
import api.dm.kit.media.synthesis.music_notes;

import Math = api.math;

/**
 * Authors: initkfs
 */
class SynthesizerPanel : Container
{
    Choice!NoteType noteDurType;

    RegulateTextField ampField;

    RegulateTextField fcField;
    RegulateTextField fmField;
    RegulateTextField fmIndexField;

    Check isFcMulFmField;

    FracSpinner aADSR;
    FracSpinner dADSR;
    FracSpinner sADSR;
    FracSpinner rADSR;

    SoundPattern* delegate() soundPatternProvider;
    void delegate() onUpdatePattern;

    this(typeof(soundPatternProvider) provider)
    {
        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout;
        layout.isAutoResize = true;

        this.soundPatternProvider = provider;
    }

    override void create()
    {
        super.create;

        auto choiceBox = new HBox;
        addCreate(choiceBox);
        choiceBox.isAlignY = true;

        noteDurType = new Choice!NoteType;
        choiceBox.addCreate(noteDurType);

        NoteType[] data = [
            NoteType.note1, NoteType.note1_2, NoteType.note1_4, NoteType.note1_8,
            NoteType.note1_16
        ];

        noteDurType.fill(data);
        noteDurType.setSelectedIndex(2);

        ampField = new RegulateTextField("Am:");
        choiceBox.addCreate(ampField);
        ampField.value = 0.7;
        ampField.scrollField.valueStep = 0.1;

        auto fmBox = new VBox;
        addCreate(fmBox);

        fcField = new RegulateTextField("FC:", 1, 10000);
        fmBox.addCreate(fcField);
        fcField.scrollField.valueStep = 1;
        fcField.value = 10;

        fmField = new RegulateTextField("FM:", 1, 10000);
        fmBox.addCreate(fmField);
        fmField.scrollField.valueStep = 1;
        fmField.value = 10;

        fmIndexField = new RegulateTextField("FI:", 1, 200);
        fmBox.addCreate(fmIndexField);
        fmIndexField.scrollField.valueStep = 1;
        fmIndexField.value = 1;

        isFcMulFmField = new Check("FC*FM");
        fmBox.addCreate(isFcMulFmField);

        auto adsrBox = new HBox;
        addCreate(adsrBox);

        aADSR = newADSRField(adsrBox);
        dADSR = newADSRField(adsrBox);
        sADSR = newADSRField(adsrBox);
        rADSR = newADSRField(adsrBox);

        fcField.onValue = (v) {
            tryChangePattern((p) { p.freqHz = v; return true; });
        };
        fmField.onValue = (v) { tryChangePattern((p) { p.fmHz = v; return true; }); };
        fmIndexField.onValue = (v) {
            tryChangePattern((p) { p.fmIndex = v; return true; });
        };
        noteDurType.onChangeOldNew ~= (oldv, newv) {
            tryChangePattern((p) { p.noteType = newv; return true; });
        };

        isFcMulFmField.onOldNewValue ~= (oldv, newv) {
            tryChangePattern((p) { p.isFcMulFm = newv; return true; });
        };
    }

    bool tryChangePattern(scope bool delegate(SoundPattern*) onPattern, bool isTriggerListeners = true)
    {

        if (!soundPatternProvider)
        {
            return false;
        }

        SoundPattern* ptr = soundPatternProvider();
        if (!ptr)
        {
            return false;
        }

        if (onPattern(ptr))
        {
            if (onUpdatePattern && isTriggerListeners)
            {
                onUpdatePattern();
            }
            return true;
        }

        return false;
    }

    void reset()
    {
        ampField.value(0.5, false);
        fcField.value(0, false);
        fmField.value(0, false);
        fmIndexField.value(0, false);
        noteDurType.setSelectedIndex(2, false);
        isFcMulFmField.isOn(false, false);
    }

    void setPattern(SoundPattern p)
    {
        noteDurType.setSelected = p.noteType;
        fcField.value = p.freqHz;
        fmField.value = p.fmHz;
        fmIndexField.value = p.fmIndex;
        adsr = p.adsr;
    }

    ADSR adsr()
    {
        ADSR value;
        value.attack = aADSR.value;
        value.decay = dADSR.value;
        value.sustain = sADSR.value;
        value.release = rADSR.value;
        return value;
    }

    void adsr(ADSR v)
    {
        aADSR.value = v.attack;
        dADSR.value = v.decay;
        sADSR.value = v.sustain;
        rADSR.value = v.release;
    }

    protected FracSpinner newADSRField(Container root)
    {
        assert(root);
        auto field = new FracSpinner(0, 0.1, 0.1);
        field.onChangeOldNew ~= (oldv, newv) {
            tryChangePattern((p) { p.adsr = adsr; return true; });
        };
        root.addCreate(field);
        return field;
    }

    double amp()
    {
        assert(ampField);
        return ampField.value;
    }

    void amp(double value)
    {
        assert(ampField);
        ampField.value = value;
    }

    bool isFcMulFm() => isFcMulFmField.isOn;

    void isFcMulFm(bool v)
    {
        assert(isFcMulFmField);
        isFcMulFmField.isOn = v;
    }

    double fm()
    {
        assert(fmField);
        return fmField.value;
    }

    double fi()
    {
        assert(fmIndexField);
        return fmIndexField.value;
    }
}
