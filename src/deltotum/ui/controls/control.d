module deltotum.ui.controls.control;

import deltotum.display.display_object : DisplayObject;
import deltotum.ui.theme.theme : Theme;
import deltotum.ui.layouts.layout: Layout;

/**
 * Authors: initkfs
 */
class Control : DisplayObject
{
    @property double minWidth = 0;
    @property double mnHeight = 0;
    @property double maxWidth = 0;
    @property double maxHeight = 0;
    @property double prefWidth = 0;
    @property double prefHeight = 0;

    @property Layout layout;

    @property void delegate() invalidateListener;

    @property Theme theme;

    this(Theme theme)
    {
        this.theme = theme;
    }

    void invalidate()
    {
        if (!isRedraw)
        {
            requestRedraw;
        }

        if (invalidateListener !is null)
        {
            invalidateListener();
        }
    }
}
