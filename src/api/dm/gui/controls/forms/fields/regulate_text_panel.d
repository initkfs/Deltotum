module api.dm.gui.controls.forms.fields.regulate_text_panel;
import api.dm.gui.controls.forms.fields.regulate_text_field : RegulateTextField;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.gui.containers.container : Container;

/**
 * Authors: initkfs
 */
class RegulateTextPanel : Container
{
    RegulateTextField[] fields;

    this(double fieldSpacing = 5)
    {
        import api.dm.kit.sprites.layouts.vlayout : VLayout;

        layout = new VLayout(fieldSpacing);
        layout.isAutoResize = true;
        layout.isAlignX = true;
    }

    override void addCreate(Sprite sprite, long index = -1)
    {
        if (auto field = cast(RegulateTextField) sprite)
        {
            //TODO check exists
            fields ~= field;
        }

        super.addCreate(sprite, index);
    }

    void alignFields()
    {
        //TODO both directions
        double maxLabelWidth = 0;
        foreach (field; fields)
        {
            if (field.labelField.width > maxLabelWidth)
            {
                maxLabelWidth = field.labelField.width;
            }
        }

        if (maxLabelWidth > 0)
        {
            foreach (field; fields)
            {
                field.labelField.width = maxLabelWidth;
            }
        }
    }

    override void dispose()
    {
        super.dispose;
        fields = null;
    }

    void setMinValue()
    {
        foreach (field; fields)
        {
            field.scrollField.setMinValue;
        }
    }

    void setMaxValue()
    {
        foreach (field; fields)
        {
            field.scrollField.setMaxValue;
        }
    }
}
