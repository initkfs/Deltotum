module api.dm.gui.controls.containers.flow_box;

import api.dm.gui.controls.containers.container : Container;
import api.dm.kit.sprites2d.layouts.flow_layout: FlowLayout;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;

/**
 * Authors: initkfs
 */
class FlowBox : Container
{
    this(float hgap = 5, float vgap = 0)
    {
        import std.exception : enforce;
        import std.conv : text;

        layout = new FlowLayout(hgap, vgap);
        layout.isAutoResize = false;
    }
}
