module deltotum.ui.containers.hbox;

import deltotum.ui.containers.container : Container;
import deltotum.toolkit.display.layouts.horizontal_layout : HorizontalLayout;

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
