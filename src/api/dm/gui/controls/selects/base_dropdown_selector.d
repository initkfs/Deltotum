module api.dm.gui.controls.selects.base_dropdown_selector;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.selects.base_selector : BaseSelector;
import api.dm.gui.controls.popups.base_popup : BasePopup;
import api.dm.gui.controls.popups.popup : Popup;

/**
 * Authors: initkfs
 */
class BaseDropDownSelector(D, T) : BaseSelector!T
{
    bool isDropDownDialog;

    D dialog;
    bool isCreateDialog = true;
    D delegate(D) onNewDialog;
    void delegate(D) onConfiguredDialog;
    void delegate(D) onCreatedDialog;

    BasePopup popup;
    BasePopup delegate(BasePopup) onNewPopup;
    void delegate(BasePopup) onConfiguredPopup;
    void delegate(BasePopup) onCreatedPopup;

    bool isIncreasePopupWidth;

    void delegate() onShowPopup;

    this(bool isCreateLayout = true)
    {
        if (isCreateLayout)
        {
            import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

            layout = new VLayout(0);
            layout.isAutoResize = true;
        }
    }

    abstract D newDialog();

    void createDialog(scope void delegate(D) onDialog)
    {
        if (!dialog && isCreateDialog)
        {
            auto d = newDialog;
            dialog = !onNewDialog ? d : onNewDialog(d);

            if (onConfiguredDialog)
            {
                onConfiguredDialog(dialog);
            }

            if (!isDropDownDialog)
            {
                addCreate(dialog);
                if (layout)
                {
                    layout.isDecreaseRootSize = true;
                }
            }
            else
            {
                createPopup;
                assert(popup);
                popup.addCreate(dialog);
            }

            if (onDialog)
            {
                onDialog(dialog);
            }

            if (onCreatedDialog)
            {
                onCreatedDialog(dialog);
            }
        }
    }

    void createPopup()
    {
        auto pp = newPopup;
        popup = !onNewPopup ? pp : onNewPopup(pp);

        if (!popup.layout)
        {
            import api.dm.kit.sprites2d.layouts.managed_layout : ManagedLayout;

            popup.layout = new ManagedLayout;
        }

        popup.layout.isAutoResize = true;

        assert(sceneProvider);
        sceneProvider().controlledSprites ~= popup;

        popup.onFocusExit ~= (ref e) {
            if (popup.isVisible)
            {
                popup.hide;
            }
        };

        if (onConfiguredPopup)
        {
            onConfiguredPopup(popup);
        }

        addCreate(popup);
        if (onCreatedPopup)
        {
            onCreatedPopup(popup);
        }

        onPointerPress ~= (ref e) { showPopup; };
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
            if (isIncreasePopupWidth && popup.width < width)
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

            if (onShowPopup)
            {
                onShowPopup();
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
