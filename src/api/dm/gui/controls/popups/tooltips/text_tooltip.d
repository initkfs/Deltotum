module api.dm.gui.controls.popups.tooltips.text_tooltip;

import api.dm.gui.controls.popups.tooltips.base_tooltip: BaseTooltip;

/**
 * Authors: initkfs
 */
class TextTooltip : BaseTooltip
{
    this(dstring text = "Tooltip", string iconName = null, float graphicsGap = 0)
    {
        super(text, iconName, graphicsGap);
    }
}
