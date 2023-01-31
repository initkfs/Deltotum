module deltotum.engine.ui.containers.hbox;

import deltotum.engine.ui.containers.container: Container;
import deltotum.engine.display.layouts.horizontal_layout: HorizontalLayout;

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
