module api.dm.gui.controls.containers.tabs.tab;

import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.switches.buttons.button : Button;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;

/**
 * Authors: initkfs
 */
class Tab : Container
{
    Button labelButton;
    bool isCreateLabelButton = true;
    Button delegate(Button) onNewLabelButton;
    void delegate(Button) onCreatedLabelButton;

    protected
    {
        dstring labelButtonText;
        string labelButtonIconName;
    }

    Sprite2d content;

    void delegate() onAction;

    void delegate() onActivate;

    this(dstring text)
    {
       this(text, null, null);
    }

    this(dstring text, string iconName)
    {
       this(text, null, iconName);
    }

    this(dstring text = "Tab", Sprite2d content = null, string iconName = null)
    {
        labelButtonText = text;
        labelButtonIconName = iconName;

        this.content = content;

        import api.dm.kit.sprites2d.layouts.center_layout : CenterLayout;

        layout = new CenterLayout;
        layout.isAutoResize = true;

        isBorder = false;
        isBackground = false;
    }

    override void create()
    {
        super.create;

        if (!labelButton && isCreateLabelButton)
        {
            auto lb = newLabelButton(labelButtonText, labelButtonIconName);
            labelButtonText = null;
            labelButton = !onNewLabelButton ? lb : onNewLabelButton(lb);

            labelButton.isFixedButton = true;
            labelButton.isAutolockButton = true;
            labelButton.isBorder = false;
            labelButton.width = width;
            labelButton.height = height;

            labelButton.onOldNewValue ~= (bool oldv, bool newv) {
                if (newv && onAction)
                {
                    onAction();
                }
            };

            addCreate(labelButton);
            if (onCreatedLabelButton)
            {
                onCreatedLabelButton(labelButton);
            }
        }
    }

    Button newLabelButton(dstring text, string iconName) => new Button(text, iconName);

    void isSelected(bool isSelected, bool isTriggerListeners = true)
    {
        if (labelButton)
        {
            labelButton.isOn(isSelected, isTriggerListeners);
        }
    }
}
