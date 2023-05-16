module deltotum.gui.supports.guieditor;

import deltotum.kit.scenes.scene : Scene;

/**
 * Authors: initkfs
 */
class GuiEditor : Scene
{
    override void create()
    {
        super.create;

        import deltotum.gui.containers.container : Container;
        import deltotum.gui.containers.hbox : HBox;
        import deltotum.gui.containers.vbox : VBox;
        import deltotum.gui.controls.texts.text_area : TextArea;
        import deltotum.gui.containers.container : Container;
        import deltotum.gui.containers.stack_box : StackBox;

        auto root = new VBox;
        root.width = window.width;
        root.height = window.height;
        root.isBackground = false;
        addCreated(root);

        auto buttonsContainer = new HBox;
        root.addCreated(buttonsContainer);

        import deltotum.gui.controls.buttons.button : Button;

        auto btn1 = new Button;
        btn1.onAction = (e) {
            interact.dialog.showQuestion("Question?", (answer) {
                import std;
                writeln(answer);
            });
        };
        btn1._buttonText = "Question";
        buttonsContainer.addCreated(btn1);

        auto btn2 = new Button;
        btn2._buttonText = "Кнопка";
        buttonsContainer.addCreated(btn2);

        auto btn3 = new Button;
        btn3._buttonText = "Кнопка";
        buttonsContainer.addCreated(btn3);

    }

}
