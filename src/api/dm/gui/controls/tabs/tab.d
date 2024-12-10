module api.dm.gui.controls.tabs.tab;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.switches.buttons.button: Button;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;

/**
 * Authors: initkfs
 */
class Tab : Control
{
    Button label;

    Sprite2d content;

    void delegate() onAction;

    this(dstring text = "Tab")
    {
        label = new Button(text);
        label.isFixedButton = true;
        label.isBorder = false;

        import api.dm.kit.sprites2d.layouts.center_layout: CenterLayout;
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
