module api.dm.gui.controls.audio.pattern_synthesizer;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.containers.base.typed_container : TypedContainer;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.gui.controls.containers.vbox : VBox;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.switches.checks.check : Check;
import api.dm.gui.controls.switches.base_biswitch : BaseBiswitch;
import api.dm.gui.controls.meters.scrolls.base_regular_mono_scroll : BaseRegularMonoScroll;
import api.dm.gui.controls.meters.scrolls.hscroll : HScroll;
import api.dm.gui.controls.switches.buttons.button : Button;
import api.dm.gui.controls.selects.spinners.spinner : FracSpinner;

import api.dm.gui.controls.forms.regulates.regulate_text_panel : RegulateTextPanel;
import api.dm.gui.controls.forms.regulates.regulate_text_field : RegulateTextField;

import api.dm.kit.media.synthesis.effect_synthesis : ADSR;
import api.dm.kit.media.synthesis.music_notes : Octave, MusicNote;

import Math = api.math;

class Pattern : BaseBiswitch
{
    double freqHz = 0;
    double fmHz = 0;
    double index = 0;
    double durationMs = 500;

    Text text;
    Button deleteThis;

    void delegate() onDelete;

    this()
    {
        import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

        layout = new HLayout;
        layout.isAutoResize = true;
        layout.isAlignY = true;
    }

    override void create()
    {
        super.create;

        deleteThis = new Button("-");
        deleteThis.width = theme.checkMarkerWidth;
        deleteThis.height = theme.checkMarkerHeight;
        addCreate(deleteThis);
        deleteThis.onAction ~= (ref e) {
            if (onDelete)
            {
                onDelete();
            }
        };

        text = new Text("(0)");
        addCreate(text);

        onOldNewValue ~= (oldv, newv) { isDrawBounds = newv; };

        onPointerPress ~= (ref e) { toggle; };
    }

    void updateData()
    {
        assert(text);
        import std.format : format;

        text.text = format("(%.02f,%.02f,%.02f)", freqHz, fmHz, index);
    }

}

class PatternPanel : Container
{
    size_t index;

    Check active;
    BaseRegularMonoScroll ampValue;

    Container patternContainer;

    Pattern[] patterns;

    Button addPattern;

    void delegate(Pattern) onPattern;
    void delegate(Pattern) onPatternDelete;

    void delegate(bool) onPatterns;

    this()
    {
        import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

        layout = new HLayout;
        layout.isAutoResize = true;
        layout.isAlignY = true;
    }

    override void create()
    {
        super.create;

        active = new Check("");
        addCreate(active);

        active.onOldNewValue ~= (oldv, newv) {
            if (onPatterns)
            {
                onPatterns(newv);
            }
        };

        ampValue = new HScroll(0, 1);
        ampValue.valueStep = 0.1;
        addCreate(ampValue);
        ampValue.value = 0.5;

        addPattern = new Button("+");
        addCreate(addPattern);

        addPattern.onAction ~= (ref e) {
            auto pattern = new Pattern;
            patterns ~= pattern;

            pattern.onOldNewValue ~= (oldv, newv) {
                if (newv && onPattern)
                {
                    foreach (p; patterns)
                    {
                        if (p is pattern)
                        {
                            continue;
                        }
                        p.isOn = false;
                    }

                    onPattern(pattern);
                }
            };

            pattern.onDelete = () {

                import api.core.utils.arrays : drop;

                drop(patterns, pattern);

                patternContainer.remove(pattern);

                if (onPatternDelete)
                {
                    onPatternDelete(pattern);
                }
            };

            patternContainer.addCreate(pattern);
        };

        patternContainer = new HBox;
        addCreate(patternContainer);
    }

}

class PatternSettings : Container
{
    FracSpinner aADSR;
    FracSpinner dADSR;
    FracSpinner sADSR;
    FracSpinner rADSR;

    RegulateTextField fcField;
    RegulateTextField fmField;
    RegulateTextField fmIndexField;

    this()
    {
        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout;
        layout.isAutoResize = true;
    }

    override void create()
    {
        super.create;

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
    }

    void reset()
    {
        fcField.value = 0;
        fmField.value = 0;
        fmIndexField.value = 0;
    }
}

/**
 * Authors: initkfs
 */
class PatternSynthesizer(T) : Control
{
    double sampleFreqHz = 0;

    void delegate(Pattern) onPattern;
    void delegate(bool, Pattern[], size_t, double) onPatterns;

    PatternSettings settings;

    protected
    {
        Pattern _current;
    }

    this(double sampleFreqHz)
    {
        assert(sampleFreqHz > 0);
        this.sampleFreqHz = sampleFreqHz;

        import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

        layout = new HLayout;
        layout.isAutoResize = true;
    }

    override void create()
    {
        super.create;

        settings = new PatternSettings;
        addCreate(settings);

        settings.fcField.onValue = (v) {
            if (_current)
            {
                _current.freqHz = v;
                _current.updateData;
            }
        };

        settings.fmField.onValue = (v) {
            if (_current)
            {
                _current.fmHz = v;
                _current.updateData;
            }
        };

        settings.fmIndexField.onValue = (v) {
            if (_current)
            {
                _current.index = v;
                _current.updateData;
            }
        };

        auto patternContainer = new VBox;
        addCreate(patternContainer);

        foreach (ip; 0 .. 5)
            (i) {
            auto patternPanel = new PatternPanel;

            patternPanel.index = i;

            patternPanel.onPatterns = (isPlay) {
                double amp = patternPanel.ampValue.value;
                if (onPatterns)
                {
                    onPatterns(isPlay, patternPanel.patterns, patternPanel.index, amp);
                }
            };

            patternPanel.onPattern = (p) {
                if (onPattern)
                {
                    onPattern(p);
                }
                _current = p;
                setPattern(p);
            };

            patternPanel.onPatternDelete = (p) {
                if (p is _current)
                {
                    _current = null;
                    settings.reset;
                }
            };

            patternContainer.addCreate(patternPanel);
        }(ip);
    }

    void setPattern(Pattern p)
    {
        assert(p);

        settings.fcField.value = p.freqHz;
        settings.fmField.value = p.fmHz;
        settings.fmIndexField.value = p.index;

    }
}
