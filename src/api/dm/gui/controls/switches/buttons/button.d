module api.dm.gui.controls.switches.buttons.button;

import api.dm.gui.controls.switches.buttons.base_button : BaseButton;
import api.dm.gui.events.action_event : ActionEvent;

/**
 * Authors: initkfs
 */
class Button : BaseButton
{
    
    this(dstring text = defaultButtonText, dchar iconName = dchar.init)
    {
        super(text, iconName);
    }

    this(dstring text = defaultButtonText, dchar iconName, void delegate(ref ActionEvent) onAction)
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
        float width,
        float height,
        dchar iconName = dchar.init,
        float graphicsGap = 0,
    )
    {
        super(text, width, height, iconName, graphicsGap);
    }

}
