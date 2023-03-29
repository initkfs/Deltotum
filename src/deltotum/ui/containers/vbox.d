module deltotum.ui.containers.vbox;

import deltotum.ui.containers.container : Container;
import deltotum.toolkit.display.layouts.vertical_layout : VerticalLayout;

/**
 * Authors: initkfs
 */
class VBox : Container
{
    double spacing = 0;
    this(double spacing = 0)
    {
        super();
        this.layout = new VerticalLayout(spacing);
    }
}
