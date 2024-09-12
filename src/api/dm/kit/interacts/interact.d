module api.dm.kit.interacts.interact;

import api.dm.kit.interacts.dialogs.dialog_manager : DialogManager;
import api.dm.kit.interacts.popups.popup_manager : PopupManager;

/**
 * Authors: initkfs
 */
class Interact
{
    protected
    {
        DialogManager _dialog;
        PopupManager _popup;
    }

    void dialog(DialogManager newDialog)
    {
        assert(newDialog);
        _dialog = newDialog;
    }

    DialogManager dialog()
    {
        assert(_dialog);
        return _dialog;
    }

    bool hasDialog()
    {
        return _dialog !is null;
    }

    void popup(PopupManager newPopup)
    {
        assert(newPopup);
        _popup = newPopup;
    }

    PopupManager popup()
    {
        assert(_popup);
        return _popup;
    }

    bool hasPopup()
    {
        return _popup !is null;
    }
}
