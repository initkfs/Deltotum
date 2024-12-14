module api.dm.gui.controls.separators.hseparator;

import api.dm.gui.controls.separators.base_separator : BaseSeparator;

/**
 * Authors: initkfs
 */
class HSeparator : BaseSeparator
{
    this()
    {
        isHGrow = true;
        isResizedByParent = true;
    }

    override void loadTheme()
    {
        super.loadTheme;

        if (height == 0)
        {
            initHeight = theme.separatorHeight;
        }

        if (width == 0)
        {
            initWidth = 1.0;
        }
    }

}
