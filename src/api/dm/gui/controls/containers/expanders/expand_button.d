module api.dm.gui.controls.containers.expanders.expand_button;

import api.dm.gui.controls.containers.expanders.expander;
import api.dm.gui.controls.control : Control;

/**
 * Authors: initkfs
 */
class ExpandButton : Expander
{
    override void configureExpandBar(Control expandBar)
    {
        super.configureExpandBar(expandBar);
        expandBar.isBackground = false;
        expandBar.isBorder = false;
        if (expandBar.hasLayout)
        {
            expandBar.layout.isAlignX = true;
            expandBar.layout.isAlignY = true;
        }
    }

    override protected void createExpandButton()
    {
        super.createExpandButton;
        if (expandButton)
        {
            expandButton.margin = 0;
        }
    }
}
