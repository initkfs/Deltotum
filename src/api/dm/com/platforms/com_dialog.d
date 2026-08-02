module api.dm.com.platforms.com_dialog;

import api.dm.com.com_result : ComResult;
import api.dm.com.graphics.com_window : ComWindow;

struct ComDialogFilter
{
    string name = "All files";
    string pattern = "*";

    static
    {
        ComDialogFilter images() => ComDialogFilter("All images", "png;jpg;jpeg");
    }
}

/**
 * Authors: initkfs
 */
interface ComDialog
{

    void initialize();
    void processCallback();

nothrow:
    void openFile(ComWindow window, void delegate(string[]) onAction, string defaultLocation = null, bool isAllowMany = true, ComDialogFilter[] filters = null);
    void openDir(ComWindow window, void delegate(string[]) onAction, string defaultLocation = null, bool isAllowMany = true);
    void saveFile(ComWindow window, void delegate(string[]) onAction, string defaultLocation = "/", ComDialogFilter[] filters = null);

}
