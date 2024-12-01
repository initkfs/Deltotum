module api.dm.gui.containers.flow_box;

import api.dm.gui.containers.container : Container;
import api.dm.kit.sprites.sprites2d.layouts.flow_layout: FlowLayout;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;

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
