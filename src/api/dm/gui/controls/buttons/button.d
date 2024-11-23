module api.dm.gui.controls.buttons.button;

import api.dm.gui.controls.buttons.base_button : BaseButton;
import api.dm.gui.events.action_event : ActionEvent;

/**
 * Authors: initkfs
 */
class Button : BaseButton
{
    
    this(dstring text = defaultButtonText, string iconName = null)
    {
        super(text, iconName);
    }

    this(dstring text, void delegate(ref ActionEvent) onAction)
    {
        super(text, onAction);
    }

    this(
        dstring text,
        double width,
        double height,
        double graphicsGap = 0,
        string iconName = null,
    )
    {
        super(text, width, height, graphicsGap, iconName);
    }

}
