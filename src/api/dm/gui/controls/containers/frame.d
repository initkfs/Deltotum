module api.dm.gui.controls.containers.frame;

import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.layouts.spaceable_layout : SpaceableLayout;
import api.dm.kit.sprites2d.layouts.vlayout : VLayout;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.switches.buttons.base_button : BaseButton;
import api.dm.gui.controls.switches.buttons.button : Button;

/**
 * Authors: initkfs
 */
class Frame : Container
{
    BaseButton label;

    bool isCreateLabel = true;
    BaseButton delegate(BaseButton) onNewLabel;
    void delegate(BaseButton) onConfiguredLabel;
    void delegate(BaseButton) onCreatedLabel;

    private
    {
        dstring initText;
    }

    this(dstring labelText = "Frame")
    {
        initText = labelText;

        import api.dm.kit.sprites2d.layouts.center_layout : CenterLayout;

        layout = new CenterLayout;
        layout.isAutoResize = true;

        isBorder = true;
    }

    override void create()
    {
        super.create;

        if (!label && isCreateLabel)
        {
            auto l = newLabel(initText);
            label = !onNewLabel ? l : onNewLabel(l);

            label.isLayoutManaged = false;
            label.isBackground = true;
            label.isBorder = true;
            label.isResizedByParent = false;

            if (onConfiguredLabel)
            {
                onConfiguredLabel(l);
            }

            addCreate(label);

            label.enablePadding;

            if (onCreatedLabel)
            {
                onCreatedLabel(label);
            }
        }

        enablePadding;

        //TODO label position;
        if (padding.top < label.height)
        {
            padding.top = label.height;
            marginTop = label.halfHeight;
        }

        invalidateListeners ~= () { setLabelPos; };
    }

    BaseButton newLabel(dstring text) => new Button(text);

    void setLabelPos()
    {
        if (!label)
        {
            return;
        }

        //TODO corrent height
        label.x = x;
        label.y = y - label.height / 2;
    }
}
