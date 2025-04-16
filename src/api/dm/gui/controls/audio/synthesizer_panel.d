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
import api.dm.gui.controls.meters.spinners.spinner : FracSpinner;
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

    Container fmContainer;

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

    this()
    {
        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout;
        layout.isAutoResize = true;
    }

    override void create()
    {
        super.create;

        auto adsrBox = new HBox;
        addCreate(adsrBox);

        aADSR = newADSRField(adsrBox);
        aADSR.onChangeOldNew ~= (oldv, newv) {
            tryChangePattern((p) { p.adsr.attack = newv; return true; });
        };

        dADSR = newADSRField(adsrBox);
        dADSR.onChangeOldNew ~= (oldv, newv) {
            tryChangePattern((p) { p.adsr.decay = newv; return true; });
        };

        sADSR = newADSRField(adsrBox);
        sADSR.onChangeOldNew ~= (oldv, newv) {
            tryChangePattern((p) { p.adsr.sustain = newv; return true; });
        };

        rADSR = newADSRField(adsrBox);
        rADSR.onChangeOldNew ~= (oldv, newv) {
            tryChangePattern((p) { p.adsr.release = newv; return true; });
        };

        auto choiceBox = new HBox;
        addCreate(choiceBox);
        choiceBox.isAlignY = true;

        ampField = new RegulateTextField("Am:");
        choiceBox.addCreate(ampField);
        ampField.value = 0.7;
        ampField.scrollField.valueStep = 0.1;

        noteDurType = new Choice!NoteType;
        choiceBox.addCreate(noteDurType);

        noteDurType.itemToTextConverter = (type) {
            final switch (type) with (NoteType)
            {
                case note1:
                    return "1";
                case note1_2:
                    return "1/2";
                case note1_4:
                    return "1/4";
                case note1_8:
                    return "1/8";
                case note1_16:
                    return "1/16";
            }
        };

        NoteType[] data = [
            NoteType.note1, NoteType.note1_2, NoteType.note1_4, NoteType.note1_8,
            NoteType.note1_16
        ];

        noteDurType.fill(data);
        noteDurType.setSelectedIndex(2);

        fmContainer = new VBox;
        addCreate(fmContainer);

        fcField = new RegulateTextField("FC:", 0, 10000);
        fmContainer.addCreate(fcField);
        fcField.scrollField.valueStep = 1;
        fcField.value = 10;

        fmField = new RegulateTextField("FM:", 01, 10000);
        fmContainer.addCreate(fmField);
        fmField.scrollField.valueStep = 1;
        fmField.value = 10;

        fmIndexField = new RegulateTextField("FI:", 1, 200);
        fmContainer.addCreate(fmIndexField);
        fmIndexField.scrollField.valueStep = 1;
        fmIndexField.value = 1;

        isFcMulFmField = new Check("FC*FM");
        fmContainer.addCreate(isFcMulFmField);

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
        isFcMulFmField.isOn = p.isFcMulFm;
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

    void adsr(ADSR v, bool isTriggerListeners = true)
    {
        //TODO one listener;
        aADSR.value(v.attack, isTriggerListeners);
        dADSR.value(v.decay, isTriggerListeners);
        sADSR.value(v.sustain, isTriggerListeners);
        rADSR.value(v.release, isTriggerListeners);
    }

    protected FracSpinner newADSRField(Container root)
    {
        assert(root);
        auto field = new FracSpinner;
        root.addCreate(field);
        return field;
    }

    double amp()
    {
        assert(ampField);
        return ampField.value;
    }

    void amp(double v, bool isTriggerListeners = true)
    {
        assert(ampField);
        ampField.value(v, isTriggerListeners);
    }

    bool isFcMulFm() => isFcMulFmField.isOn;

    void isFcMulFm(bool v, bool isTriggerListeners = true)
    {
        assert(isFcMulFmField);
        isFcMulFmField.isOn(v, isTriggerListeners);
    }

    double fc()
    {
        assert(fcField);
        return fcField.value;
    }

    void fc(double v, bool isTriggerListeners = true)
    {
        assert(fcField);
        fcField.value(v, isTriggerListeners);
    }

    double fm()
    {
        assert(fmField);
        return fmField.value;
    }

    void fm(double v, bool isTriggerListeners = true)
    {
        assert(fmField);
        fmField.value(v, isTriggerListeners);
    }

    double fmIndex()
    {
        assert(fmIndexField);
        return fmIndexField.value;
    }

    void fmIndex(double v, bool isTriggerListeners = true)
    {
        assert(fmIndexField);
        fmIndexField.value(v, isTriggerListeners);
    }

    void noteType(NoteType type, bool isTriggerListeners = true)
    {
        assert(noteDurType);
        noteDurType.setSelected(type, isTriggerListeners);
    }

    NoteType noteType()
    {
        assert(noteDurType);
        return noteDurType.current;
    }
}
