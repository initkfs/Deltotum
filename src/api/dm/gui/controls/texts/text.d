module api.dm.gui.controls.texts.text;

import api.dm.gui.controls.texts.base_mono_text : BaseMonoText;

/**
 * Authors: initkfs
 */
class Text : BaseMonoText
{
    this(string text)
    {
        super(text);
    }

    this(dstring text = "")
    {
        super(text);
    }
}
