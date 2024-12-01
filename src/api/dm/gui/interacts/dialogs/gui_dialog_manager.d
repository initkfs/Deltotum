module api.dm.gui.interacts.dialogs.gui_dialog_manager;

import api.dm.gui.interacts.dialogs.gui_dialog : GuiDialog;
import api.dm.kit.interacts.dialogs.dialog_manager : DialogManager;
import api.dm.kit.components.graphics_component : GraphicsComponent;
import api.dm.kit.scenes.scene2d : Scene2d;
import api.dm.kit.windows.window : Window;
import api.math.geom2.rect2 : Rect2d;
import api.dm.gui.containers.container : Container;
import api.dm.gui.containers.stack_box : StackBox;
import api.dm.kit.interacts.interact : Interact;
import api.dm.kit.interacts.dialogs.dialog_manager : DialogManager;

/**
 * Authors: initkfs
 */
class GuiDialogManager : Container, DialogManager
{
    GuiDialog mainDialog;

    bool isDialogLazyCreate;

    void delegate(GuiDialog) onDialogCreate;

    this(GuiDialog dialog = null)
    {
        mainDialog = !dialog ? new GuiDialog : dialog;
        mainDialog.isLayoutManaged = false;
    }

    override void initialize()
    {
        super.initialize;

        if (!mainDialog.onExit)
        {
            mainDialog.onExit = () { hideDialog; };
        }
    }

    override void create()
    {
        super.create;

        if (!isDialogLazyCreate)
        {
            createDialog(mainDialog);
            if (mainDialog.isVisible)
            {
                mainDialog.isVisible = false;
            }
        }
    }

    protected void createDialog(GuiDialog dialog)
    {
        addCreate(dialog);
        if (onDialogCreate)
        {
            onDialogCreate(mainDialog);
        }
    }

    protected void showDialog()
    {
        assert(mainDialog);

        if (!mainDialog.isBuilt)
        {
            createDialog(mainDialog);
        }

        const sceneBounds = graphics.renderBounds;
        mainDialog.x = sceneBounds.middleX - mainDialog.boundsRect.halfWidth;
        mainDialog.y = sceneBounds.middleY - mainDialog.boundsRect.halfHeight;

        mainDialog.isVisible = true;
    }

    void hideDialog()
    {
        mainDialog.isVisible = false;
    }

    void showInfo(dstring text, dstring title = "Info", void delegate() onAction = null)
    {
        showDialog;
        mainDialog.messageText = text;
        mainDialog.titleText = title;
        if (onAction)
        {
            mainDialog.onAction = onAction;
        }
    }

    void showError(dstring text, dstring title = "Error", void delegate() onAction = null)
    {
        showDialog;
        mainDialog.messageText = text;
        mainDialog.titleText = title;
        if (onAction)
        {
            mainDialog.onAction = onAction;
        }
    }

    void showQuestion(dstring text, dstring title = "Question", void delegate(bool) onResult = null)
    {
        showDialog;
        mainDialog.messageText = text;
        mainDialog.titleText = title;
    }
}
