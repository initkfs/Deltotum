module dm.gui.controls.texts.textfield;

import dm.gui.controls.texts.text : Text, CursorState, CursorPos;

/**
 * Authors: initkfs
 */
class TextField : Text
{
    this(string text)
    {
        import std.conv : to;

        this(text.to!dstring);
        isEditable = true;
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
        import dm.math.insets : Insets;

        _padding = Insets(5);
    }
}
