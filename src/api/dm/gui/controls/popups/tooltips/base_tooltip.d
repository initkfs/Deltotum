module api.dm.gui.controls.popups.tooltips.base_tooltip;

import api.dm.gui.controls.popups.base_text_popup: BaseTextPopup;

/**
 * Authors: initkfs
 */
class BaseTooltip : BaseTextPopup
{
    protected
    {

    }

    this(dstring text, string iconName, double graphicsGap)
    {
        super(text, iconName, graphicsGap, isCreateLayout : true);
    }
}
