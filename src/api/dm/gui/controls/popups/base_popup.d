module api.dm.gui.controls.popups.base_popup;

import api.dm.gui.controls.labeled : Labeled;

/**
 * Authors: initkfs
 */
class BasePopup : Labeled
{
    protected
    {

    }

    this(dstring text = "Popup", string iconName = null, double graphicsGap = 0, bool isCreateLayout = true)
    {
        super(0, 0, text, iconName, graphicsGap, isCreateLayout);
        _labelText = text;

        isDrawByParent = false;

        isBorder = false;
        isCreateHover = false;
        isCreateHoverAnimation = false;
        isCreateActionEffect = false;
        isCreateActionEffectAnimation = false;

        isVisible = false;
        isLayoutManaged = false;
        isBorder = true;
        isBackground = true;
    }

    override void create()
    {
        super.create;
        enableInsets;
    }
}
