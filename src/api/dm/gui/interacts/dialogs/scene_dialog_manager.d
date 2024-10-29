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
                    window.scenes.currentScene.isPause = false;
                }
            };
        }
    }

    override protected void createDialog(GuiDialog dialog)
    {
        super.createDialog(dialog);
        assert(window);
        assert(window.scenes);
        window.scenes.currentScene.controlledSprites ~= this;
        window.scenes.currentScene.eternalSprites ~= this;
    }

    override protected void showDialog()
    {
        super.showDialog;

        if (isEnableScenePause)
        {
            window.scenes.currentScene.isPause = true;
        }
    }

}
