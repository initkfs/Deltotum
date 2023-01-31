module deltotum.engine.ui.containers.stack_box;

import deltotum.engine.ui.containers.container : Container;
import deltotum.engine.display.layouts.center_layout: CenterLayout;

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
