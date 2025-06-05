module api.dm.gui.controls.forms.regulates.regulate_text_field;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.meters.scrolls.base_regular_mono_scroll : BaseRegularMonoScroll;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.texts.text_view: TextView;

/**
 * Authors: initkfs
 */
class RegulateTextField : Control
{
    Text labelField;
    bool isCreateLabelField = true;
    Text delegate(Text) onNewLabelField;
    void delegate(Text) onConfiguredLabelField;
    void delegate(Text) onCreatedLabelField;

    BaseRegularMonoScroll scrollField;
    bool isCreateScrollField = true;
    BaseRegularMonoScroll delegate(BaseRegularMonoScroll) onNewScrollField;
    void delegate(BaseRegularMonoScroll) onConfiguredScrollField;
    void delegate(BaseRegularMonoScroll) onCreatedScrollField;

    TextView valueField;
    bool isCreateValueField = true;
    TextView delegate(TextView) onNewValueField;
    void delegate(TextView) onConfiguredValueField;
    void delegate(TextView) onCreatedValueField;

    dstring valueFieldInitSymbol = "0";

    size_t valueFieldPrefGlyphs = 6;

    void delegate(double) onValue;

    protected
    {
        dstring labelText;
        double minValue = 0;
        double maxValue = 0;
        void delegate(double) onScroll;

        double lastValue = 0;
    }

    import api.dm.kit.sprites2d.layouts.spaceable_layout : SpaceableLayout;

    this(dstring labelText, double minValue = 0, double maxValue = 1.0, void delegate(
            double) onScroll = null, double fieldSpacing = SpaceableLayout.DefaultSpacing)
    {
        this(fieldSpacing);
        this.labelText = labelText;
        this.minValue = minValue;
        this.maxValue = maxValue;
        this.onScroll = onScroll;
    }

    this(double fieldSpacing = SpaceableLayout.DefaultSpacing)
    {
        import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

        layout = new HLayout(fieldSpacing);
        layout.isAutoResize = true;
        layout.isDecreaseRootSize = true;
        layout.isAlignY = true;
    }

    override void create()
    {
        super.create;

        if (!labelField && isCreateLabelField)
        {
            auto lf = newLabelField(labelText);
            labelField = !onNewLabelField ? lf : onNewLabelField(lf);

            labelField.isReduceWidthHeight = false;

            if (onConfiguredLabelField)
            {
                onConfiguredLabelField(labelField);
            }

            addCreate(labelField);
            if (onCreatedLabelField)
            {
                onCreatedLabelField(labelField);
            }
        }

        if (!scrollField && isCreateScrollField)
        {
            auto sf = newScrollField;
            scrollField = !onNewScrollField ? sf : onNewScrollField(sf);

            scrollField.minValue = minValue;
            scrollField.maxValue = maxValue;

            scrollField.onValue ~= (v) {
                updateValue(v, isTriggerListeners:
                    true);
                updateValueField(v, isTriggerListeners:
                    true);
                if (onScroll)
                {
                    onScroll(v);
                }
            };

            if (onConfiguredScrollField)
            {
                onConfiguredScrollField(scrollField);
            }

            addCreate(scrollField);
            if (onCreatedScrollField)
            {
                onCreatedScrollField(scrollField);
            }
        }

        if (!valueField && isCreateValueField)
        {
            auto fv = newValueField(valueFieldInitSymbol);
            valueField = !onNewValueField ? fv : onNewValueField(fv);

            valueField.isReduceWidthHeight = false;
            valueField.isEditable = true;

            valueField.onEnter = (ref e) {
                import std.conv : to;

                try
                {
                    auto v = valueField.text.to!double;
                    updateValue(v, isTriggerListeners:
                        true);
                    scrollField.value(v, isTriggerListeners:
                        false);
                    if (onScroll)
                    {
                        onScroll(v);
                    }
                }
                catch (Exception e)
                {
                    //TODO dialog
                    logger.error(e.toString);
                }
            };

            if (onConfiguredValueField)
            {
                onConfiguredValueField(valueField);
            }

            addCreate(valueField);

            auto glyphW = valueField.calcTextWidth(valueFieldInitSymbol, valueField.fontSize);
            auto newWidth = valueFieldPrefGlyphs * glyphW;
            if (newWidth > valueField.width)
            {
                valueField.width = newWidth;
            }

            if (onCreatedValueField)
            {
                onCreatedValueField(valueField);
            }
        }

    }

    Text newLabelField(dstring text) => new Text(text);
    TextView newValueField(dstring text) => new TextView(text);

    BaseRegularMonoScroll newScrollField()
    {
        import api.dm.gui.controls.meters.scrolls.hscroll : HScroll;

        return new HScroll;
    }

    double value() => lastValue;

    protected bool updateValue(double v, bool isTriggerListeners = true)
    {
        lastValue = v;

        if (onValue && isTriggerListeners)
        {
            onValue(v);
        }

        return true;
    }

    protected bool updateScrollField(double v, bool isTriggerListeners = true)
    {
        if (!scrollField)
        {
            return false;
        }

        scrollField.value(v, isTriggerListeners);
        return true;
    }

    protected bool updateValueField(double v, bool isTriggerListeners = true)
    {
        if (!valueField)
        {
            return false;
        }

        import std.format : format;

        if (!valueField)
        {
            return false;
        }
        auto text = format("%.2f", v);
        valueField.text(text, isTriggerListeners);
        return true;
    }

    bool value(double v, bool isTriggerListeners = true)
    {
        if (lastValue == v)
        {
            return false;
        }

        bool isUpdate;

        isUpdate |= updateValue(v, isTriggerListeners);
        isUpdate |= updateScrollField(v, isTriggerListeners);
        isUpdate |= updateValueField(v, isTriggerListeners);

        return isUpdate;
    }

    bool setMinValue() => value(minValue);
    bool setMaxValue() => value(maxValue);
}
