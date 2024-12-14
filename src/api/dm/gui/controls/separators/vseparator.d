module api.dm.gui.controls.separators.vseparator;

import api.dm.gui.controls.separators.base_separator : BaseSeparator;

/**
 * Authors: initkfs
 */
class VSeparator : BaseSeparator
{
    this()
    {
        isVGrow = true;
        isResizedByParent = true;
    }

    override void loadTheme()
    {
        super.loadTheme;

        if (width == 0)
        {
            initWidth = theme.separatorHeight;
        }

        if (height == 0)
        {
            initHeight = 1.0;
        }
    }

}
