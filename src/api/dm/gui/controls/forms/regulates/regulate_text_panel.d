module api.dm.gui.controls.forms.regulates.regulate_text_panel;
import api.dm.gui.controls.forms.regulates.regulate_text_field : RegulateTextField;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.containers.container : Container;

/**
 * Authors: initkfs
 */
class RegulateTextPanel : Container
{
    RegulateTextField[] fields;

    bool isInsets = true;

    import api.dm.kit.sprites2d.layouts.spaceable_layout : SpaceableLayout;

    this(double fieldSpacing = SpaceableLayout.DefaultSpacing)
    {
        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout(fieldSpacing);
        layout.isAutoResize = true;
        layout.isDecreaseRootSize = true;
    }

    override void create(){
        super.create;

        if(isInsets){
            enableInsets;
        }
    }

    alias add = Container.add;

    override void add(Sprite2d obj, long index = -1)
    {
        super.add(obj, index);

        if (auto field = cast(RegulateTextField) obj)
        {
            fields ~= field;
        }
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
