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
        super(0, 0, iconName, graphicsGap, text, isCreateLayout);
        _labelText = text;

        isDrawByParent = false;

        isBorder = false;
        isCreateHoverEffectFactory = false;
        isCreateHoverAnimationFactory = false;
        isCreateActionEffectFactory = false;
        isCreateActionAnimationFactory = false;

        isVisible = false;
        isLayoutManaged = false;
        isBorder = true;
        isBackground = true;
    }

    override void create(){
        super.create;
        enableInsets;
    }
}
