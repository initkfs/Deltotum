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

        if (_width == 0)
        {
            _width = theme.separatorHeight;
        }

        assert(_width > 0);

        if (_height == 0)
        {
            _height = 1;
        }
    }

}
