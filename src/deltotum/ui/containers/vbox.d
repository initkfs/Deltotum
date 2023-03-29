module deltotum.ui.containers.vbox;

import deltotum.ui.containers.container : Container;
import deltotum.toolkit.display.layouts.vertical_layout : VerticalLayout;

/**
 * Authors: initkfs
 */
class VBox : Container
{
    double spacing = 0;

    this(double spacing = 0) pure
    {
        import std.exception : enforce;
        import std.conv : text;

        enforce(spacing >= 0, text("Vertical spacing must be positive value: ", spacing));
        this.spacing = spacing;

        this.layout = new VerticalLayout(spacing);
    }
}
