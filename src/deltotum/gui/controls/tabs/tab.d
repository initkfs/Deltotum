module deltotum.gui.controls.tabs.tab;

import deltotum.gui.containers.container : Container;
import deltotum.gui.controls.buttons.button : Button;
import deltotum.kit.display.display_object: DisplayObject;

/**
 * Authors: initkfs
 */
class Tab : Container
{
    private
    {
        Button textButton;
    }

    //TODO inconsistency without adding\creating
    DisplayObject content;

    void delegate() onAction;

    this(dstring text = "Tab")
    {
        textButton = new Button;
        textButton.text = text;
    }

    override void initialize()
    {
        super.initialize;

        width = textButton.width;
        height = textButton.height;
    }

    override void create()
    {
        super.create;

          textButton.onAction = (e) {
            if (onAction)
            {
                onAction();
            }
        };

        addCreated(textButton);
    }
}
