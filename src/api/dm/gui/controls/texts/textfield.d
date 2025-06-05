module api.dm.gui.controls.texts.textfield;

import api.dm.gui.controls.texts.text : Text;

/**
 * Authors: initkfs
 */
class TextField : Text
{
    this(dstring text = "")
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
        import api.math.insets : Insets;

        _padding = Insets(5);
    }
}
