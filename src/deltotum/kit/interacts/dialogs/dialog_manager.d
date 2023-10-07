module deltotum.kit.interacts.dialogs.dialog_manager;

import deltotum.kit.windows.window : Window;
import deltotum.kit.apps.comps.window_component: WindowComponent;

import deltotum.kit.scenes.scene : Scene;

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
            addCreate(root);

            import deltotum.gui.controls.texts.text : Text;

            auto text = new Text;
            text.text = contentText;
            root.addCreate(text);

            import deltotum.gui.containers.hbox : HBox;

            auto buttonPanel = new HBox(5);
            root.addCreate(buttonPanel);

            import deltotum.gui.controls.buttons.button : Button;

            auto okButton = new Button();
            okButton.text = "OK";
            okButton.onAction = (ref e) {
                if (onOk)
                {
                    onOk();
                }
            };
            auto cancelButton = new Button();
            cancelButton.text = "Cancel";
            cancelButton.onAction = (ref e) {
                if (onCancel)
                {
                    onCancel();
                }
            };

            buttonPanel.addCreate(okButton);
            buttonPanel.addCreate(cancelButton);
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
        dialogWindow.resize(400, 200);
        dialogWindow.isDecorated(false);
        return dialogWindow;
    }

    void showQuestion(dstring text, void delegate(bool) onResult)
    {
        auto win = createDialog;
        win.title = "Question";

        if(parentWindowProvider){
            auto parentWindow = parentWindowProvider();
            if(parentWindow){
                const parentBounds = parentWindow.bounds;
                const newX = cast(int) (parentBounds.width / 2 - win.width / 2);
                const newY = cast(int) (parentBounds.height / 2 - win.height / 2);
                win.pos(newX, newY);
            }
        }

        auto scene = new DialogScene();
        scene.onOk = () { win.close; onResult(true); };
        scene.onCancel = () { win.close; onResult(false); };
        scene.contentText = text;
        win.scenes.addCreate(scene);
        win.show;
    }
}
