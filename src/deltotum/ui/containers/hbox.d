module deltotum.ui.containers.hbox;

import deltotum.ui.containers.container: Container;
import deltotum.ui.theme.theme : Theme;
import deltotum.display.layouts.horizontal_layout: HorizontalLayout;

/**
 * Authors: initkfs
 */
class HBox : Container
{
    @property double spacing = 0;

    this(Theme theme, double spacing = 0)
    {
       super(theme);
       this.layout = new HorizontalLayout(spacing);
    }
}
