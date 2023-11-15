module dm.gui.containers.circle_box;

import dm.gui.containers.container : Container;
import dm.kit.sprites.layouts.circle_layout: CircleLayout;
import dm.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
class CircleBox : Container
{
    this(double radius = 80) pure
    {
        import std.exception : enforce;

        layout = new CircleLayout(radius);
        layout.isAutoResize = true;
    }
}
