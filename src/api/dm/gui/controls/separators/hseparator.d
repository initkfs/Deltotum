module api.dm.gui.controls.separators.hseparator;

import api.dm.gui.controls.separators.separator: Separator;

/**
 * Authors: initkfs
 */
class HSeparator : Separator
{
    this(double height = 2)
    {
        this.height = height;

        isBorder = false;
        isBackground = true;
        isHGrow = true;
    }

}
