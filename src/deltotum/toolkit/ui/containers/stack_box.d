module deltotum.toolkit.ui.containers.stack_box;

import deltotum.toolkit.ui.containers.container : Container;
import deltotum.toolkit.display.layouts.center_layout: CenterLayout;

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
