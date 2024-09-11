module api.dm.kit.interacts.interact;

import api.dm.kit.interacts.dialogs.dialog_manager : DialogManager;

/**
 * Authors: initkfs
 */
class Interact
{
    protected
    {
        DialogManager _dialog;
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
}
