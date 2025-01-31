module api.dm.gui.controls.containers.circle_box;

import api.dm.gui.controls.containers.container : Container;
import api.dm.kit.sprites2d.layouts.circle_layout: CircleLayout;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;

/**
 * Authors: initkfs
 */
class CircleBox : Container
{
    this(double radius = 80, double startAngle = 0)
    {
        import std.exception : enforce;

        auto newLayout = new CircleLayout(radius);
        newLayout.startAngle = startAngle;
        this.layout = newLayout;
        layout.isAutoResize = true;
    }
}
