module api.dm.gui.controls.tabs.tab;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.switches.locks.lock_switch: LockSwitch;
import api.dm.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
class Tab : Control
{
    LockSwitch label;

    Sprite content;

    void delegate() onAction;

    this(dstring text = "Tab")
    {
        label = new LockSwitch(text);
        label.isBorder = false;

        import api.dm.kit.sprites.layouts.center_layout: CenterLayout;
        layout = new CenterLayout;
        layout.isAutoResize = true;

        isBorder = false;
        isBackground = false;
    }

    override void create()
    {
        super.create;

        buildInitCreate(label);

        width = label.width;
        height = label.height;

        add(label);

        label.onOldNewValue ~= (bool oldv, bool newv) {
            if (newv && onAction)
            {
                onAction();
            }
        };
    }

    void isSelected(bool isSelected){
        if(label){
            label.isOn = isSelected;
        }
    }
}
