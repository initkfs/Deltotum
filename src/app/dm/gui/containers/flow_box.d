module app.dm.gui.containers.flow_box;

import app.dm.gui.containers.container : Container;
import app.dm.kit.sprites.layouts.flow_layout: FlowLayout;
import app.dm.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
class FlowBox : Container
{
    this(double hgap = 5, double vgap = 0)
    {
        import std.exception : enforce;
        import std.conv : text;

        layout = new FlowLayout(hgap, vgap);
        layout.isAutoResize = false;
    }
}
