module api.dm.gui.interacts.dialogs.gui_dialog_manager;

import api.dm.kit.interacts.dialogs.dialog_manager : DialogManager;
import api.dm.kit.components.graphics_component : GraphicsComponent;
import api.dm.kit.scenes.scene : Scene;
import api.dm.kit.windows.window : Window;
import api.math.rect2d : Rect2d;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.gui.containers.container : Container;
import api.dm.kit.interacts.interact : Interact;
import api.dm.kit.interacts.dialogs.dialog_manager : DialogManager;

class Dialog : Container
{
    import api.dm.gui.controls.texts.text : Text;

    void delegate() onAction;
    void delegate() onExit;

    protected
    {
        Text _title;
        Text _message;
    }

    this()
    {
        _width = 200;
        _height = 300;
        isBackground = true;
        isBorder = true;
    }

    import api.dm.kit.inputs.pointers.events.pointer_event : PointerEvent;
    import api.dm.kit.events.event_kit_target: EventKitPhase;

    override void onEventPhase(ref PointerEvent e, EventKitPhase phase){
        super.onEventPhase(e, phase);
        if(phase != EventKitPhase.postDispatch){
            return;
        }
        e.isConsumed = true;
    }

    override void create()
    {
        super.create;
        //TODO focus
        import api.dm.gui.containers.vbox : VBox;

        auto root = new VBox(5);
        addCreate(root);

        _title = new Text("Title");
        _title.isHGrow = true;
        root.addCreate(_title);

        _message = new Text("Message");
        _message.isHGrow = true;
        root.addCreate(_message);

        import api.dm.gui.containers.hbox: HBox;
        import api.dm.gui.controls.buttons.button : Button;

        auto buttonPanel = new HBox(5);
        root.addCreate(buttonPanel);
        buttonPanel.isHGrow = true;

        auto buttonOk = new Button("OK");
        buttonPanel.addCreate(buttonOk);
        buttonOk.onAction = (ref e) { 
            if(onAction){
                onAction();
                onAction = null;
            }
            
            if(onExit){
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
    protected
    {
        Dialog mainDialog;
    }

    this(Dialog dialog = null)
    {
        mainDialog = !dialog ? new Dialog : dialog;
        mainDialog.isLayoutManaged = false;
        isVisible = false;

        isDrawByParent = false;
    }

    override void create()
    {
        super.create;

        mainDialog.onExit = (){
            hideDialog;
        };
    }

    protected void showDialog()
    {
        assert(mainDialog);

        if (!mainDialog.isBuilt)
        {
            addCreate(mainDialog);
            window.scenes.currentScene.controlledSprites ~= this;
        }

        const sceneBounds = window.bounds;
        mainDialog.x = sceneBounds.middleX - mainDialog.bounds.halfWidth;
        mainDialog.y = sceneBounds.middleY - mainDialog.bounds.halfHeight;

        mainDialog.isVisible = true;
        isVisible = true;
    }

    void hideDialog(){
        mainDialog.isVisible = false;
        isVisible = false;
    }

    void showInfo(dstring text, void delegate() onAction = null)
    {
        showDialog;
        mainDialog.message = text;
        if(onAction){
            mainDialog.onAction = onAction;
        }
    }

    void showError(dstring text, void delegate() onAction = null)
    {
        showDialog;
        mainDialog.message = text;
        if(onAction){
            mainDialog.onAction = onAction;
        }
    }

    void showQuestion(dstring text, void delegate(bool) onResult = null)
    {
        showDialog;
        mainDialog.message = text;
    }
}
