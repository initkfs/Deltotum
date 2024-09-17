module api.dm.kit.interacts.dialogs.dialog_manager;

/**
 * Authors: initkfs
 */
interface DialogManager
{
    void showInfo(dstring text, dstring title = "Info", void delegate() onResult = null);
    void showError(dstring text, dstring title = "Error", void delegate() onResult = null);
    void showQuestion(dstring text, dstring title = "Question", void delegate(bool) onResult = null);
}
