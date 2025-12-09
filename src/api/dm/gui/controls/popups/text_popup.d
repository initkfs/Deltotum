module api.dm.gui.controls.popups.text_popup;

import api.dm.gui.controls.popups.base_text_popup: BaseTextPopup;

/**
 * Authors: initkfs
 */
class TextPopup : BaseTextPopup
{
    protected
    {

    }

    this(dstring text = "Popup", string iconName = null, float graphicsGap = 0)
    {
        super(text, iconName, graphicsGap, isCreateLayout : true);
    }
}
