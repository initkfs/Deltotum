module api.sims.ele.components.base_component;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.popups.tooltips.text_tooltip : TextTooltip;

/**
 * Authors: initkfs
 */

class BaseComponent : Control
{

    TextTooltip tooltip;

    string formatTooltip()
    {
        return null;
    }

    void createTooltip()
    {
        if (tooltip)
        {
            logger.warning("Replace tooltip in component: ", toString);
        }

        tooltip = new TextTooltip;

        tooltip.onShow ~= () {
            string text = formatTooltip;
            assert(tooltip.label);
            tooltip.label.text = text;
        };

        installTooltip(tooltip);
    }

}
