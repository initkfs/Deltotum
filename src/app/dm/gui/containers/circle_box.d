module app.dm.gui.containers.circle_box;

import app.dm.gui.containers.container : Container;
import app.dm.kit.sprites.layouts.circle_layout: CircleLayout;
import app.dm.kit.sprites.sprite : Sprite;

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
