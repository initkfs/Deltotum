module api.dm.gui.controls.separators.vseparator;

import api.dm.gui.controls.separators.separator: Separator;

/**
 * Authors: initkfs
 */
class VSeparator : Separator
{
    this(double width = 2)
    {
        this.width = width;

        isBorder = false;
        isBackground = true;
        isVGrow = true;
    }

}
