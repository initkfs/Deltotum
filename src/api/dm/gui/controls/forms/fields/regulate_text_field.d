module api.dm.gui.controls.forms.fields.regulate_text_field;

import api.dm.gui.controls.scrolls.mono_scroll : MonoScroll;
import api.dm.gui.controls.texts.text : Text;

import api.dm.gui.controls.control : Control;

/**
 * Authors: initkfs
 */
class RegulateTextField : Control
{
    Text labelField;
    MonoScroll scrollField;
    Text valueField;

    size_t valueFieldPrefGlyphs = 6;

    protected
    {
        dstring labelText;
        double minValue = 0;
        double maxValue = 0;
        void delegate(double) onScroll;
    }

    this(dstring labelText, double minValue = 0, double maxValue = 1.0, void delegate(
            double) onScroll = null, double fieldSpacing = 5)
    {
        this(fieldSpacing);
        this.labelText = labelText;
        this.minValue = minValue;
        this.maxValue = maxValue;
        this.onScroll = onScroll;
    }

    this(double fieldSpacing = 5)
    {
        import api.dm.kit.sprites.layouts.hlayout : HLayout;

        layout = new HLayout(fieldSpacing);
        layout.isAutoResize = true;
        layout.isAlignY = true;
    }

    override void create()
    {
        super.create;

        labelField = new Text(labelText);
        labelField.isReduceWidthHeight = false;
        addCreate(labelField);

        import api.dm.gui.controls.scrolls.hscroll : HScroll;

        scrollField = new HScroll;
        addCreate(scrollField);
        scrollField.minValue = minValue;
        scrollField.maxValue = maxValue;
        scrollField.onValue ~= onScroll;

        valueField = new Text("Value");
        valueField.isReduceWidthHeight = false;
        valueField.isEditable = true;
        addCreate(valueField);

        auto glyphW = valueField.calcTextWidth("0", valueField.fontSize);
        auto newWidth = valueFieldPrefGlyphs * glyphW;
        if (newWidth < valueField.width)
        {
            valueField.width = newWidth;
        }

        scrollField.onValue ~= (v) { valueText(v); };
    }

    double value(){
        assert(scrollField);
        return scrollField.value;
    }

    bool value(double v)
    {
        if (!scrollField || !valueField)
        {
            return false;
        }

        scrollField.value = v;
        return valueText(v);
    }

    bool valueText(double v)
    {
        import std.format : format;

        if (!valueField)
        {
            return false;
        }
        valueField.text = format("%.2f", v);
        return true;
    }

    bool setMinValue()
    {
        assert(scrollField);
        return scrollField.setMinValue;
    }

    bool setMaxValue()
    {
        assert(scrollField);
        return scrollField.setMaxValue;
    }
}
