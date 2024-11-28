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

    this(dstring text = defaultButtonText, string iconName, void delegate(ref ActionEvent) onAction)
    {
        this(text, iconName);
        this.onAction ~= onAction;
    }

    this(dstring text, void delegate(ref ActionEvent) onAction)
    {
        super(text, onAction);
    }

    this(
        dstring text,
        double width,
        double height,
        string iconName = null,
        double graphicsGap = 0,
    )
    {
        super(text, width, height, iconName, graphicsGap);
    }

}
