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
import api.dm.gui.controls.selects.choices.choice : Choice;

import api.dm.gui.controls.forms.regulates.regulate_text_panel : RegulateTextPanel;
import api.dm.gui.controls.forms.regulates.regulate_text_field : RegulateTextField;

import api.dm.kit.media.synthesis.effect_synthesis : ADSR;
import api.dm.kit.media.synthesis.music_notes;
import api.dm.gui.controls.audio.synthesizer_panel : SynthesizerPanel;
import api.dm.gui.controls.audio.sound_pattern_item : SoundPatternItem;
import api.dm.kit.media.synthesis.sound_pattern : SoundPattern;

import Math = api.math;

class PatternPanel : Container
{
    size_t index;

    Check active;
    BaseRegularMonoScroll ampValue;

    Container patternContainer;

    SoundPatternItem[] patterns;

    Button addPattern;

    void delegate(SoundPatternItem) onPattern;
    void delegate(SoundPatternItem) onPatternDelete;
    void delegate(SoundPatternItem, double amp) onPatternPlay;

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
            auto pattern = newPattern;
            patternContainer.addCreate(pattern);
        };

        patternContainer = new HBox;
        addCreate(patternContainer);
    }

    SoundPatternItem newPattern()
    {
        auto pattern = new SoundPatternItem;
        patterns ~= pattern;

        pattern.onPlay = () {
            if (onPatternPlay)
            {
                onPatternPlay(pattern, ampValue.value);
            }
        };

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

        pattern.onInsertNext = () {
            auto newP = newPattern;

            newP.pattern = pattern.pattern;
            newP.updateData;

            auto oldIndex = patternContainer.findChildIndex(pattern);
            if (oldIndex != -1)
            {
                auto newIndex = oldIndex + 1;
                if (newIndex < patternContainer.children.length)
                {
                    patternContainer.addCreate(newP, newIndex);
                }
                else
                {
                    patternContainer.addCreate(newP);
                }

            }

        };

        return pattern;
    }
}

/**
 * Authors: initkfs
 */
class PatternSynthesizer(T) : Control
{
    double sampleFreqHz = 0;

    void delegate(SoundPatternItem) onPattern;
    void delegate(SoundPatternItem, double) onPlay;
    void delegate(bool, SoundPatternItem[], size_t, double) onPatterns;

    SynthesizerPanel settings;

    protected
    {
        SoundPatternItem _current;
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

        settings = new SynthesizerPanel(() {
            if (!_current)
            {
                return null;
            }
            return &_current.pattern;
        });

        addCreate(settings);
        settings.enablePadding;

        settings.onUpdatePattern = () {
            if (_current)
            {
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
                settings.setPattern(_current.pattern);
            };

            patternPanel.onPatternDelete = (p) {
                if (p is _current)
                {
                    _current = null;
                    settings.reset;
                }
            };

            patternPanel.onPatternPlay = (p, amp) {
                if (!_current || !onPlay)
                {
                    return;
                }
                onPlay(p, amp);
            };

            patternContainer.addCreate(patternPanel);
        }(ip);
    }
}
