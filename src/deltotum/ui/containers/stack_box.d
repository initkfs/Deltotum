module deltotum.ui.containers.stack_box;

import deltotum.ui.containers.container : Container;
import deltotum.display.layouts.center_layout: CenterLayout;

/**
 * Authors: initkfs
 */
class StackBox : Container
{
    this()
    {
        super();
        this.layout = new CenterLayout;
    }
}
