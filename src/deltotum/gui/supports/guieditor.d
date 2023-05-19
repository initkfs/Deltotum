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
        import deltotum.gui.controls.buttons.button : Button;

        enum size = 30;
        auto circle1 = new Circle(size / 2, GraphicStyle(5, RGBA.green));
        auto circle2 = new Circle(size / 2, GraphicStyle(5, RGBA.green, true, RGBA.red));
        auto rect1 = new Rectangle(size, size, GraphicStyle(5, RGBA.green));
        auto rect2 = new Rectangle(size, size, GraphicStyle(5, RGBA.green, true, RGBA.red));
        shapeContainer.addCreate([circle1, circle2, rect1, rect2]);

        auto posContainer = new HBox;
        root.addCreate(posContainer);

        auto startToEndContainer = new HBox;
        startToEndContainer.width = 350;
        posContainer.addCreate(startToEndContainer);

        startToEndContainer.addCreate([
            new Button, new Button, new Button
        ]);

        auto fillBothContainer = new HBox(1);
        fillBothContainer.width = 450;
        posContainer.addCreate(fillBothContainer);

        auto fbBtn1 = new Button("ExpandH");
        fbBtn1.isHGrow = true;

        fillBothContainer.addCreate([
            new Button, fbBtn1, new Button
        ]);

        auto endToStartContainer = new HBox;
        endToStartContainer.isFillFromStartToEnd = false;
        endToStartContainer.width = 350;
        posContainer.addCreate(endToStartContainer);
        endToStartContainer.addCreate([
            new Button, new Button, new Button
        ]);

        auto textsContainer = new HBox;
        root.addCreate(textsContainer);

        auto startEndVBox = new VBox;
        startEndVBox.height = 200;
        textsContainer.addCreate(startEndVBox);
        startEndVBox.addCreate([
            new Button, new Button, new Button
        ]);

        import deltotum.gui.controls.texts.text : Text;

        auto text1 = new Text;
        textsContainer.addCreate(text1);
        text1.text = "Text";

        import deltotum.gui.controls.texts.text_area : TextArea;

        auto textarea1 = new TextArea;
        textarea1.width = 350;
        textarea1.height = 150;
        textsContainer.addCreate(textarea1);
        textarea1.textView.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";

        auto endStartVBox = new VBox;
        endStartVBox.isFillFromStartToEnd = false;
        endStartVBox.height = 200;
        textsContainer.addCreate(endStartVBox);
        endStartVBox.addCreate([
            new Button, new Button, new Button
        ]);

        auto fillVBox = new VBox;
        fillVBox.height = 200;
        textsContainer.addCreate(fillVBox);
        auto fillVBtn1 = new Button;
        fillVBtn1.isVGrow = true;
        fillVBtn1.isHGrow = true;
        fillVBox.addCreate([
            fillVBtn1, new Button
        ]);

    }

}
