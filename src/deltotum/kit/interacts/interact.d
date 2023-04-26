module deltotum.kit.interacts.interact;

import deltotum.kit.interacts.dialogs.dialog_manager: DialogManager;

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
