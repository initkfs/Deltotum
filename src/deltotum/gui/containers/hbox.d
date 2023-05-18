module deltotum.gui.containers.hbox;

import deltotum.gui.containers.container : Container;
import deltotum.kit.sprites.layouts.horizontal_layout : HorizontalLayout;
import deltotum.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
class HBox : Container
{
    double spacing = 0;

    this(double spacing = 10) pure
    {
        import std.exception : enforce;
        import std.conv : text;

        enforce(spacing >= 0, text("Horizontal spacing must be positive value or 0: ", spacing));
        this.spacing = spacing;

        this.layout = new HorizontalLayout(spacing);
    }
}
