module deltotum.gui.containers.stack_box;

import deltotum.gui.containers.container : Container;
import deltotum.kit.sprites.layouts.center_layout: CenterLayout;

/**
 * Authors: initkfs
 */
class StackBox : Container
{
    this()
    {
        this.layout = new CenterLayout;
    }
}