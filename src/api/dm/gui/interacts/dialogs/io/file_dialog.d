module api.dm.gui.interacts.dialogs.io.file_dialog;

import api.dm.gui.controls.control : Control;
import api.dm.com.platforms.com_dialog : ComDialog, ComDialogFilter;

import api.dm.back.sdl3.sdl_dialog;

/**
 * Authors: initkfs
 */
class FileDialog : Control
{
    ComDialog nativeDialog;

    override void create()
    {
        super.create;
        nativeDialog = interact.comDialogProvider()();
        nativeDialog.initialize;
    }

    void openFile(void delegate(string[]) onAction, string defaultLocation = null, bool isAllowMany = true, ComDialogFilter[] filters = null)
    {
        nativeDialog.openFile(window.comWindow, onAction, defaultLocation, isAllowMany, filters);
    }

    void openDir(void delegate(string[]) onAction, string defaultLocation = null, bool isAllowMany = true)
    {
        nativeDialog.openDir(window.comWindow, onAction, defaultLocation, isAllowMany);
    }

    void saveFile(void delegate(string[]) onAction, string defaultLocation = "/", ComDialogFilter[] filters = null)
    {
        nativeDialog.saveFile(window.comWindow, onAction, defaultLocation, filters);
    }

    override void update(float dt)
    {
        super.update(dt);

        if (!nativeDialog)
        {
            return;
        }

        nativeDialog.processCallback;
    }

}
