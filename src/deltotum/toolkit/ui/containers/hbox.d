module deltotum.toolkit.ui.containers.hbox;

import deltotum.toolkit.ui.containers.container: Container;
import deltotum.toolkit.display.layouts.horizontal_layout: HorizontalLayout;

/**
 * Authors: initkfs
 */
class HBox : Container
{
    double spacing = 0;

    this(double spacing = 0)
    {
       this.layout = new HorizontalLayout(spacing);
    }
}
