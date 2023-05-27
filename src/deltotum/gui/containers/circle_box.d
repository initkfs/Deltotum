module deltotum.gui.containers.circle_box;

import deltotum.gui.containers.container : Container;
import deltotum.kit.sprites.layouts.circle_layout: CircleLayout;
import deltotum.kit.sprites.sprite : Sprite;

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
