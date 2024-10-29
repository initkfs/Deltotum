module api.dm.gui.interacts.dialogs.gui_dialog_manager;

import api.dm.kit.interacts.dialogs.dialog_manager : DialogManager;
import api.dm.kit.components.graphics_component : GraphicsComponent;
import api.dm.kit.scenes.scene : Scene;
import api.dm.kit.windows.window : Window;
import api.math.geom2.rect2 : Rect2d;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.gui.containers.stack_box : StackBox;
import api.dm.kit.interacts.interact : Interact;
import api.dm.kit.interacts.dialogs.dialog_manager : DialogManager;

class Dialog : StackBox
{
    import api.dm.gui.controls.texts.text : Text;
    import api.dm.gui.controls.buttons.button : Button;

    void delegate() onAction;
    void delegate() onExit;

    //protected
    //{
    Text _title;
    Text _message;
    //}

    void delegate(Text) onMessageNew;
    void delegate(Button) onButtonNew;

    this()
    {
        _width = 100;
        _height = 150;
        isBackground = true;
        isBorder = true;
        isLayoutManaged = false;
    }

    import api.dm.kit.inputs.pointers.events.pointer_event : PointerEvent;
    import api.dm.kit.events.event_kit_target : EventKitPhase;

    override void onEventPhase(ref PointerEvent e, EventKitPhase phase)
    {
        super.onEventPhase(e, phase);
        if (phase != EventKitPhase.postDispatch)
        {
            return;
        }
        e.isConsumed = true;
    }

    override void create()
    {
        super.create;

        enableInsets;
        //TODO focus
        import api.dm.gui.containers.vbox : VBox;

        auto root = new VBox(5);
        root.isGrow = true;
        root.width = width;
        root.height = height;
        addCreate(root);
        root.enableInsets;
        root.layout.isAlignX = true;

        _title = new Text("Title");
        _title.isHGrow = true;
        root.addCreate(_title);

        _message = new Text("Message");
        _message.isHGrow = true;
        _message.isVGrow = true;
        if(onMessageNew){
            onMessageNew(_message);
        }
        root.addCreate(_message);

        import api.dm.gui.containers.hbox : HBox;
        

        auto buttonPanel = new HBox(5);
        root.addCreate(buttonPanel);
        //buttonPanel.isHGrow = true;

        auto buttonOk = new Button("OK");
        if(onButtonNew){
            onButtonNew(buttonOk);
        }
        buttonPanel.addCreate(buttonOk);
        buttonOk.onAction = (ref e) {
            if (onAction)
            {
                onAction();
                onAction = null;
            }

            if (onExit)
            {
                onExit();
            }
        };
    }

    void title(dstring text)
    {
        assert(_title);
        _title.text = text;
    }

    void message(dstring msg)
    {
        assert(_message);
        _message.text = msg;
    }

}

/**
 * Authors: initkfs
 */
class GuiDialogManager : Sprite, DialogManager
{
    Dialog mainDialog;

    bool isEnableScenePause = true;
    bool isDisableScenePause = true;

    void delegate(Dialog) onDialogCreate;

    this(Dialog dialog = null)
    {
        mainDialog = !dialog ? new Dialog : dialog;
        mainDialog.isLayoutManaged = false;
        isVisible = false;

        isDrawByParent = false;
        isLayoutManaged = false;
    }

    override void create()
    {
        super.create;

        mainDialog.onExit = () {
            hideDialog;
            if (isDisableScenePause)
            {
                window.scenes.currentScene.isPause = false;
            }
        };
    }

    protected void showDialog()
    {
        assert(mainDialog);

        if (!mainDialog.isBuilt)
        {
            addCreate(mainDialog);
            window.scenes.currentScene.controlledSprites ~= this;
            window.scenes.currentScene.unlockSprites ~= this;
            if (onDialogCreate)
            {
                onDialogCreate(mainDialog);
            }
        }

        const sceneBounds = graphics.renderBounds;
        mainDialog.x = sceneBounds.middleX - mainDialog.bounds.halfWidth;
        mainDialog.y = sceneBounds.middleY - mainDialog.bounds.halfHeight;

        mainDialog.isVisible = true;
        isVisible = true;
        if(isEnableScenePause){
            window.scenes.currentScene.isPause = true;
        }
    }

    void hideDialog()
    {
        mainDialog.isVisible = false;
        isVisible = false;
    }

    void showInfo(dstring text, dstring title = "Info", void delegate() onAction = null)
    {
        showDialog;
        mainDialog.message = text;
        mainDialog.title = title;
        if (onAction)
        {
            mainDialog.onAction = onAction;
        }
    }

    void showError(dstring text, dstring title = "Error", void delegate() onAction = null)
    {
        showDialog;
        mainDialog.message = text;
        mainDialog.title = title;
        if (onAction)
        {
            mainDialog.onAction = onAction;
        }
    }

    void showQuestion(dstring text, dstring title = "Question", void delegate(bool) onResult = null)
    {
        showDialog;
        mainDialog.message = text;
        mainDialog.title = title;
    }
}
