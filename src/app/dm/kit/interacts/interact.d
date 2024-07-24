module app.dm.kit.interacts.interact;

import app.dm.kit.interacts.dialogs.dialog_manager: DialogManager;

/**
 * Authors: initkfs
 */
class Interact
{
    DialogManager dialog;

    this(DialogManager dialogManager){
        assert(dialogManager);
        this.dialog = dialogManager;
    }
}
