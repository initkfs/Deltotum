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
import api.dm.gui.controls.meters.spinners.spinner : FracSpinner;
import api.dm.gui.controls.selects.choices.choice : Choice;

import api.dm.gui.controls.forms.regulates.regulate_text_panel : RegulateTextPanel;
import api.dm.gui.controls.forms.regulates.regulate_text_field : RegulateTextField;

import api.dm.kit.media.dsp.synthesis.effect_synthesis : ADSR;
import api.dm.kit.media.audio.music_notes;
import api.dm.gui.controls.audio.synthesizer_panel : SynthesizerPanel;
import api.dm.gui.controls.audio.sound_pattern_item : SoundPatternItem;
import api.dm.kit.media.audio.patterns.sound_pattern : SoundPattern;

import api.dm.gui.controls.audio.patterns.converters.pattern_converter : PatternConverter;

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
        addPattern.resize(theme.meterThumbWidth, theme.meterThumbHeight);

        addPattern.onAction ~= (ref e) {
            auto pattern = newPattern;
            patternContainer.addCreate(pattern);
        };

        patternContainer = new HBox;
        addCreate(patternContainer);
    }

    bool clear()
    {
        if (patterns.length == 0)
        {
            return false;
        }
        foreach (p; patterns)
        {
            patternContainer.remove(p);
        }
        patterns = null;
        return true;
    }

    SoundPatternItem createPattern()
    {
        auto pattern = newPattern;
        patternContainer.addCreate(pattern);
        return pattern;
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

                newP.updateData;
            }

            //TODO throw Exception?
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

    PatternPanel[] patternPanels;

    string loadFile;
    string saveFile;

    PatternConverter converter;

    Container patternContainer;

    protected
    {
        SoundPatternItem _current;
    }

    this(double sampleFreqHz, PatternConverter converter = null)
    {
        assert(sampleFreqHz > 0);
        this.sampleFreqHz = sampleFreqHz;

        import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

        layout = new HLayout;
        layout.isAutoResize = true;

        this.converter = converter ? converter : new PatternConverter;
    }

    override void create()
    {
        super.create;

        settings = new SynthesizerPanel;
        settings.soundPatternProvider = () {
            if (!_current)
            {
                return null;
            }
            return &_current.pattern;
        };

        addCreate(settings);
        settings.enablePadding;

        settings.onUpdatePattern = () {
            if (_current)
            {
                _current.updateData;
            }
        };

        patternContainer = new VBox;
        addCreate(patternContainer);

        foreach (ip; 0 .. 5)
            (i) { createPatternPanel(i); }(ip);

        auto bottomBox = new HBox;
        patternContainer.addCreate(bottomBox);

        auto loadBtn = new Button("Load");
        loadBtn.onAction ~= (ref ea) {
            try
            {
                foreach (p; patternPanels)
                {
                    patternContainer.remove(p);
                    //p.clear;
                }

                patternPanels = null;

                assert(converter);
                converter.load(loadFile, (i, patternsArr) {
                    //TODO reuse

                    auto panel = createPatternPanel(i);
                    foreach (p; patternsArr)
                    {
                        auto patternItem = panel.createPattern;
                        patternItem.pattern = p;
                        patternItem.updateData;
                    }
                });
            }
            catch (Exception ex)
            {
                logger.error(ex.toString);
            }
        };
        bottomBox.addCreate(loadBtn);

        auto saveBtn = new Button("Save");
        bottomBox.addCreate(saveBtn);
        saveBtn.onAction ~= (ref e) {
            try
            {
                SoundPattern[][] ps;
                foreach (panel; patternPanels)
                {
                    SoundPattern[] pts;
                    foreach (p; panel.patterns)
                    {
                        pts ~= p.pattern;
                    }

                    if (pts.length > 0)
                    {
                        ps ~= pts;
                    }
                }
                assert(converter);
                converter.save(ps, saveFile);
            }
            catch (Exception ex)
            {
                logger.error(ex.toString);
            }
        };
    }

    PatternPanel createPatternPanel(size_t index)
    {
        auto patternPanel = new PatternPanel;
        patternPanels ~= patternPanel;

        patternPanel.index = index;

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
        return patternPanel;
    }
}
