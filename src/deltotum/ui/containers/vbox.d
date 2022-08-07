module deltotum.ui.containers.vbox;

import deltotum.ui.containers.container : Container;
import deltotum.ui.theme.theme : Theme;
import deltotum.display.layouts.vertical_layout : VerticalLayout;

/**
 * Authors: initkfs
 */
class VBox : Container
{
    @property double spacing = 0;
    this(Theme theme, double spacing = 0)
    {
        super(theme);
        this.layout = new VerticalLayout(spacing);
    }
}
