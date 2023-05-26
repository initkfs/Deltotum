module deltotum.gui.containers.flow_box;

import deltotum.gui.containers.container : Container;
import deltotum.kit.sprites.layouts.flow_layout: FlowLayout;
import deltotum.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
class FlowBox : Container
{
    this(double hgap = 5, double vgap = 0) pure
    {
        import std.exception : enforce;
        import std.conv : text;

        layout = new FlowLayout(hgap, vgap);
        layout.isAutoResize = false;
    }
}
