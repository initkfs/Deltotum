module api.dm.kit.interacts.dialogs.dialog_manager;

/**
 * Authors: initkfs
 */
interface DialogManager
{
    void showInfo(dstring text, void delegate(bool) onResult = null);
    void showError(dstring text, void delegate(bool) onResult = null);
    void showQuestion(dstring text, void delegate(bool) onResult = null);
}
