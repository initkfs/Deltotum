module api.dm.gui.controls.buttons.button;

import api.dm.gui.controls.buttons.button_base : ButtonBase;
import api.dm.gui.events.action_event : ActionEvent;

/**
 * Authors: initkfs
 */
class Button : ButtonBase
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
        double width = defaultWidth,
        double height = defaultHeight,
        double graphicsGap = defaultGraphicsGap,
        string iconName = null
    )
    {
        super(text, width, height, graphicsGap, iconName);
    }

}
