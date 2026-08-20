module api.dm.gui.controls.containers.tabs.tab;

import api.dm.gui.controls.control : Control;
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
        dchar labelButtonIconName;
    }

    Sprite2d content;

    void delegate() onAction;

    void delegate() onActivate;

    this(dstring text, bool isAutoResize = true, Control[] children = null)
    {
        this(text, null, dchar.init, isAutoResize, children);
    }

    this(dstring text, dchar iconName, bool isAutoResize = true, Control[] children = null)
    {
        this(text, null, iconName, isAutoResize, children);
    }

    this(dstring text = "Tab", Sprite2d content, dchar iconName = dchar.init, bool isAutoResize = true, Control[] children = null)
    {
        super(() {
            import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

            import api.dm.kit.sprites2d.layouts.center_layout : CenterLayout;

            auto layout = new CenterLayout;
            layout.isAutoResize = isAutoResize;
            return layout;
        }, true, null, children);

        labelButtonText = text;
        labelButtonIconName = iconName;

        this.content = content;

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

            labelButton.onChangeOldNew ~= (bool oldv, bool newv) {
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

    Button newLabelButton(dstring text, dchar iconName) => new Button(text, iconName);

    void isSelected(bool isSelected, bool isTrigger = true)
    {
        if (labelButton)
        {
            labelButton.isOn(isSelected, isTrigger);
        }
    }
}
