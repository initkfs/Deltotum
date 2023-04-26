module deltotum.kit.interacts.dialogs.dialog_manager;

import deltotum.kit.windows.window : Window;
import deltotum.kit.applications.components.graphics_component : GraphicsComponent;

import deltotum.kit.scene.scene : Scene;

private
{
    class DialogScene : Scene
    {
        dstring contentText;
        void delegate() onOk;
        void delegate() onCancel;

        override void create()
        {
            super.create;

            import deltotum.gui.containers.vbox : VBox;

            auto root = new VBox(5);
            root.width = window.width;
            root.height = window.height;
            addCreated(root);

            import deltotum.gui.controls.texts.text : Text;

            auto text = new Text;
            text.text = contentText;
            root.addCreated(text);

            import deltotum.gui.containers.hbox : HBox;

            auto buttonPanel = new HBox(5);
            root.addCreated(buttonPanel);

            import deltotum.gui.controls.buttons.button : Button;

            auto okButton = new Button();
            okButton.text = "OK";
            okButton.onAction = (e) {
                if (onOk)
                {
                    onOk();
                }
            };
            auto cancelButton = new Button();
            cancelButton.text = "Cancel";
            cancelButton.onAction = (e) {
                if (onCancel)
                {
                    onCancel();
                }
            };

            buttonPanel.addCreated(okButton);
            buttonPanel.addCreated(cancelButton);
        }
    }
}

/**
 * Authors: initkfs
 */
class DialogManager
{
    Window delegate() dialogWindowProvider;
    Window delegate() parentWindowProvider;

    protected Window createDialog()
    {
        assert(dialogWindowProvider);

        Window dialogWindow = dialogWindowProvider();
        dialogWindow.setSize(400, 200);
        dialogWindow.setDecorated(false);
        return dialogWindow;
    }

    void showQuestion(dstring text, void delegate(bool) onResult)
    {
        auto win = createDialog;
        win.setTitle("Question");

        if(parentWindowProvider){
            auto parentWindow = parentWindowProvider();
            if(parentWindow){
                const parentBounds = parentWindow.bounds;
                const newX = cast(int) (parentBounds.width / 2 - win.width / 2);
                const newY = cast(int) (parentBounds.height / 2 - win.height / 2);
                win.setPos(newX, newY);
            }
        }

        auto scene = new DialogScene();
        scene.onOk = () { win.close; onResult(true); };
        scene.onCancel = () { win.close; onResult(false); };
        scene.contentText = text;
        win.scenes.add(scene);
        win.show;
    }
}
