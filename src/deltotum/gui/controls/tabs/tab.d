module deltotum.gui.controls.tabs.tab;

import deltotum.gui.controls.control : Control;
import deltotum.gui.controls.buttons.button : Button;
import deltotum.kit.sprites.sprite : Sprite;

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

        import deltotum.kit.sprites.layouts.center_layout: CenterLayout;
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

    void isSelected(bool isSelected){
        label.isSelected(isSelected);
    }
}
