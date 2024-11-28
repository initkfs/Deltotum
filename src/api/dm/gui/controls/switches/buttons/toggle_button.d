module api.dm.gui.controls.switches.buttons.toggle_button;

import api.dm.gui.controls.switches.buttons.base_toggle_button : BaseToggleButton;

/**
 * Authors: initkfs
 */
class ToggleButton : BaseToggleButton
{

    this(dstring text, string iconName)
    {
        this(text, 0, 0, iconName, 0);
    }

    this(dstring text)
    {
        this(text, 0, 0, null, 0);
    }

    this(
        dstring text,
        double width = 0,
        double height = 0,
        string iconName = null,
        double graphicsGap = 0,
    )
    {
        super(text, width, height, iconName, graphicsGap, isCreateLayout:
            true);
    }

}
