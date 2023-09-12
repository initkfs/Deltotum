module deltotum.gui.controls.texts.textfield;

import deltotum.gui.controls.texts.text : Text, CursorState, CursorPos;

/**
 * Authors: initkfs
 */
class TextField : Text
{
    this(string text)
    {
        import std.conv : to;

        this(text.to!dstring);
    }

    this(dstring text)
    {
        super(text);
        isBorder = true;
    }

    override void initialize()
    {
        super.initialize;
    }

    override void create()
    {
        super.create;
        import deltotum.math.geom.insets : Insets;

        _padding = Insets(5);
    }
}
