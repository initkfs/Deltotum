module deltotum.gui.supports.guieditor;

import deltotum.kit.scenes.scene : Scene;

/**
 * Authors: initkfs
 */
class GuiEditor : Scene
{
    this()
    {
        name = "deltotum_gui_editor";
    }

    override void create()
    {
        super.create;

        import deltotum.gui.containers.container : Container;
        import deltotum.gui.containers.hbox : HBox;
        import deltotum.gui.containers.vbox : VBox;
        import deltotum.gui.controls.texts.text_area : TextArea;
        import deltotum.gui.containers.container : Container;
        import deltotum.gui.containers.stack_box : StackBox;
        import deltotum.math.geometry.insets : Insets;

        auto root = new VBox;
        root.width = window.width;
        root.height = window.height;
        root.isBackground = false;
        addCreate(root);

        auto shapeContainer = new HBox;
        root.addCreate(shapeContainer);

        import deltotum.kit.graphics.colors.palettes.material_design_palette : MaterialDesignPalette;
        import deltotum.kit.graphics.colors.rgba : RGBA;
        import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
        import deltotum.kit.graphics.shapes.circle : Circle;
        import deltotum.kit.graphics.shapes.rectangle : Rectangle;

        enum size = 30;
        auto circle1 = new Circle(size / 2, GraphicStyle(5, RGBA.green));
        auto circle2 = new Circle(size / 2, GraphicStyle(5, RGBA.green, true, RGBA.red));
        auto rect1 = new Rectangle(size, size, GraphicStyle(5, RGBA.green));
        auto rect2 = new Rectangle(size, size, GraphicStyle(5, RGBA.green, true, RGBA.red));
        shapeContainer.addCreate([circle1, circle2, rect1, rect2]);

        auto buttonsContainer = new HBox;
        root.addCreate(buttonsContainer);

        import deltotum.gui.controls.buttons.button : Button;

        auto btn1 = new Button;
        btn1.onAction = (e) {
            interact.dialog.showQuestion("Question?", (answer) {
                import std;

                writeln(answer);
            });
        };
        btn1._buttonText = "Question";
        buttonsContainer.addCreate(btn1);

        auto btn2 = new Button;
        btn2._buttonText = "Кнопка";
        btn2.margin = Insets(0, 0, 0, 50);
        buttonsContainer.addCreate(btn2);

        auto btn3 = new Button;
        btn3._buttonText = "Кнопка";
        buttonsContainer.addCreate(btn3);

        auto buttonsContainer2 = new HBox;
        root.addCreate(buttonsContainer2);

        auto btnFull = new Button;
        btnFull.isHGrow = true;
        btnFull._buttonText = "Кнопка";
        buttonsContainer2.width = 200;
        buttonsContainer2.addCreate(btnFull);

    }

}
