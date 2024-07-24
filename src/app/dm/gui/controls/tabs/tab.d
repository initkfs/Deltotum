module app.dm.gui.controls.tabs.tab;

import app.dm.gui.controls.control : Control;
import app.dm.gui.controls.buttons.button : Button;
import app.dm.kit.sprites.sprite : Sprite;

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

        import app.dm.kit.sprites.layouts.center_layout: CenterLayout;
        layout = new CenterLayout;
        layout.isAutoResize = true;

        isBorder = false;
        isBackground = false;
    }

    override void create()
    {
        super.create;

        buildCreate(label);

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
