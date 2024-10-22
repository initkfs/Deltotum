module api.dm.gui.controls.tabs.tab;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.buttons.button : Button;
import api.dm.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
class Tab : Control
{
    Button label;

    Sprite content;

    void delegate() onAction;

    this(dstring text = "Tab")
    {
        label = new Button(text);
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

        label.onAction = (ref e) {
            if (onAction)
            {
                onAction();
            }
        };
    }

    override void isSelected(bool isSelected){
        label.isSelected(isSelected);
    }
}
