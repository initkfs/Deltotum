module api.dm.gui.interacts.dialogs.scene_dialog_manager;

import api.dm.gui.interacts.dialogs.gui_dialog_manager : GuiDialogManager;
import api.dm.gui.interacts.dialogs.gui_dialog : GuiDialog;

/**
 * Authors: initkfs
 */
class SceneDialogManager : GuiDialogManager
{
    bool isEnableScenePause = true;
    bool isDisableScenePause = true;

    this(GuiDialog dialog = null)
    {
        super(dialog);

        isDrawByParent = false;
        isLayoutManaged = false;
    }

    override void initialize()
    {
        super.initialize;

        if (!mainDialog.onExit)
        {
            mainDialog.onExit = () {
                hideDialog;
                if (isDisableScenePause)
                {
                    window.currentScene.isPause = false;
                }
            };
        }
    }

    override protected void createDialog(GuiDialog dialog)
    {
        super.createDialog(dialog);
        assert(window);
        assert(window);
        window.currentScene.controlledSprites ~= this;
        window.currentScene.eternalSprites ~= this;
    }

    override protected void showDialog()
    {
        super.showDialog;

        if (isEnableScenePause)
        {
            window.currentScene.isPause = true;
        }
    }

}
