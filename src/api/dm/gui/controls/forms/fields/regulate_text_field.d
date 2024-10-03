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

        labelField = new Text("Label");
        labelField.isReduceWidthHeight = false;
        addCreate(labelField);

        import api.dm.gui.controls.scrolls.hscroll : HScroll;

        scrollField = new HScroll;
        addCreate(scrollField);

        valueField = new Text("Value");
        valueField.isReduceWidthHeight = false;
        valueField.isEditable = true;
        addCreate(valueField);
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

}
