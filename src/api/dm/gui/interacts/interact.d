module api.dm.gui.interacts.interact;

import api.dm.com.platforms.com_dialog : ComDialog, ComDialogFilter;
import api.dm.gui.interacts.dialogs.dialog_manager : DialogManager;
import api.dm.gui.interacts.popups.popup_manager : PopupManager;

/**
 * Authors: initkfs
 */
class Interact
{

    protected
    {
        DialogManager _dialog;
        PopupManager _popup;

        ComDialog delegate() _comDialogProvider;
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

    ComDialog delegate() comDialogProvider()
    {
        assert(_comDialogProvider);
        return _comDialogProvider;
    }

    void comDialogProvider(ComDialog delegate() dg)
    {
        assert(dg);
        this._comDialogProvider = dg;
    }
}
