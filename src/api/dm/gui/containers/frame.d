module api.dm.gui.containers.frame;

import api.dm.gui.containers.container : Container;
import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.sprites2d.layouts.vlayout : VLayout;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.texts.text : Text;

/**
 * Authors: initkfs
 */
class Frame : Container
{
    Text label;

    private
    {
        dstring initText;
    }

    this(dstring labelText = "Frame", double spacing = 5)
    {
        initText = labelText;

        isBorder = true;

        import api.dm.kit.sprites.sprites2d.layouts.hlayout : HLayout;

        layout = new HLayout(spacing);
        layout.isAutoResize = true;
        layout.isAlignY = true;
    }

    override void create()
    {
        super.create;

        import api.dm.gui.controls.texts.text : Text;

        label = new Text(initText);
        label.isLayoutManaged = false;
        label.isFocusable = false;
        label.isBackground = true;
        label.isBorder = true;
        label.isResizedByParent = false;
        addCreate(label);

        label.enableInsets;

        enableInsets;

        label.updateRows(isForce : true);

        //TODO label position;
        if (padding.top < label.height)
        {
            padding.top = label.height;
        }

        invalidateListeners ~= (){
            setLabelPos;
        };

    }

    void setLabelPos()
    {
        if (!label)
        {
            return;
        }
        label.x = x;
        label.y = y - label.height / 2;
    }
}
