module deltotum.engine.ui.containers.vbox;

import deltotum.engine.ui.containers.container : Container;
import deltotum.engine.display.layouts.vertical_layout : VerticalLayout;

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
