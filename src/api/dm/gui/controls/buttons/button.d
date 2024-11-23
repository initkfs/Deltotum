module api.dm.gui.controls.buttons.button;

import api.dm.gui.controls.buttons.base_button : BaseButton;
import api.dm.gui.events.action_event : ActionEvent;

/**
 * Authors: initkfs
 */
class Button : BaseButton
{
    this(dstring text = "Button", string iconName)
    {
        super(text, iconName);
    }

    this(dstring text = "Button", void delegate(ref ActionEvent) onAction)
    {
        super(text, null);
        this.onAction = onAction;
    }

    this(
        dstring text = "Button",
        double width = 0,
        double height = 0,
        double graphicsGap = 0,
        string iconName = null,
    )
    {
        super(text, width, height, graphicsGap, iconName, isCreateLayout:
            true);
    }

}
