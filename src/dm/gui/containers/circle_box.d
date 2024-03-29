module dm.gui.containers.circle_box;

import dm.gui.containers.container : Container;
import dm.kit.sprites.layouts.circle_layout: CircleLayout;
import dm.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
class CircleBox : Container
{
    this(double radius = 80, double startAngle = 0) pure
    {
        import std.exception : enforce;

        auto newLayout = new CircleLayout(radius);
        newLayout.startAngle = startAngle;
        this.layout = newLayout;
        layout.isAutoResize = true;
    }
}
