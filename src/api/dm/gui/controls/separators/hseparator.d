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

        if (_height == 0)
        {
            _height = theme.separatorHeight;
        }

        assert(_height > 0);

        if (_width == 0)
        {
            _width = 1;
        }
    }

}
