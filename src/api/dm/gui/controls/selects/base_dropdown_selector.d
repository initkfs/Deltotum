module api.dm.gui.controls.selects.base_dropdown_selector;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.selects.base_selector : BaseSelector;
import api.dm.gui.controls.popups.base_popup : BasePopup;
import api.dm.gui.controls.popups.popup : Popup;

/**
 * Authors: initkfs
 */
class BaseDropDownSelector(T) : BaseSelector!T
{
    bool isDropDownDialog = true;

    BasePopup popup;
    BasePopup delegate(BasePopup) onNewPopup;
    void delegate(BasePopup) onCreatedPopup;

    this(){
        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout(0);
        layout.isAutoResize = true;
    }

    void createPopup()
    {
        auto pp = newPopup;
        popup = !onNewPopup ? pp : onNewPopup(pp);

        assert(sceneProvider);
        sceneProvider().controlledSprites ~= popup;

        popup.onFocusExit ~= (ref e) {
            if (popup.isVisible)
            {
                popup.hide;
            }
        };

        addCreate(popup);
        if (onCreatedPopup)
        {
            onCreatedPopup(popup);
        }

        onPointerPress ~= (ref e) {showPopup;};
    }

    void togglePopup()
    {
        if (!popup)
        {
            return;
        }
        if (popup.isVisible)
        {
            popup.hide;
            return;
        }

        showPopup;
    }

    void showPopup()
    {
        if (popup && !popup.isVisible)
        {
            if (popup.width < width)
            {
                popup.width = width;
            }

            auto newX = boundsRect.middleX - popup.halfWidth;
            auto newY = boundsRect.bottom;

            popup.show(newX, newY);

            if (!popup.isFocus)
            {
                popup.focus;
            }
        }
    }

    override void onRemoveFromParent()
    {
        if (popup && sceneProvider)
        {
            sceneProvider().removeControlled(popup);
        }
    }

    BasePopup newPopup() => new Popup;

}
