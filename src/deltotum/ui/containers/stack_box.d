module deltotum.ui.containers.stack_box;

import deltotum.ui.containers.container : Container;
import deltotum.ui.theme.theme : Theme;
import deltotum.ui.layouts.center_layout: CenterLayout;

/**
 * Authors: initkfs
 */
class StackBox : Container
{
    this(Theme theme)
    {
        super(theme);
        this.layout = new CenterLayout;
    }
}
