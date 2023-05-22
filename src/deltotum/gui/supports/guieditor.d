module deltotum.gui.supports.guieditor;

import deltotum.kit.scenes.scene : Scene;
import deltotum.kit.graphics.colors.rgba : RGBA;

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
        auto fillVBtn1 = new Button("ExpVH");
        fillVBtn1.isVGrow = true;
        fillVBtn1.isHGrow = true;
        fillVBox.addCreate([
                fillVBtn1, new Button
            ]);

        auto iconsContainer = new HBox;
        iconsContainer.isBackground = false;

        import deltotum.kit.sprites.images.image : Image;

        auto image1 = new Image();
        build(image1);
        image1.loadRaw(graphics.theme.iconData("rainy-outline"), 64, 64);
        image1.setColor(graphics.theme.colorAccent);

        auto image2 = new Image();
        build(image2);
        image2.loadRaw(graphics.theme.iconData("thunderstorm-outline"), 64, 64);
        image2.setColor(graphics.theme.colorAccent);

        auto image3 = new Image();
        build(image3);
        image3.loadRaw(graphics.theme.iconData("sunny-outline"), 64, 64);
        image3.setColor(graphics.theme.colorAccent);

        auto image4 = new Image();
        build(image4);
        image4.loadRaw(graphics.theme.iconData("cloudy-night-outline"), 64, 64);
        image4.setColor(graphics.theme.colorAccent);

        auto image5 = new Image();
        build(image5);
        image5.loadRaw(graphics.theme.iconData("flash-outline"), 64, 64);
        image5.setColor(graphics.theme.colorAccent);

        root.addCreate(iconsContainer);
        iconsContainer.addCreate([image1, image2, image3, image4, image5]);

        auto vectorContainers = new HBox;
        root.addCreate(vectorContainers);
        if (cap.isVectorGraphics)
        {
            import deltotum.math.geometry.curves.spirograph: Spirograph;
            import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
            import deltotum.kit.graphics.shapes.vectors.vpoints_shape : VPointsShape;
            import deltotum.math.vector2d: Vector2d;

            auto spirGen = new Spirograph;
            Vector2d[] points1 = spirGen.hypotrochoidPoints(30, 1, 27, 20);
            auto spir1 = new VPointsShape(points1, 150, 150, GraphicStyle(2, graphics.theme.colorAccent));

            Vector2d[] points2 = spirGen.hypotrochoidPoints(30, 1, 29, 8);
            auto spir2 = new VPointsShape(points2, 150, 150, GraphicStyle(2, graphics.theme.colorAccent));

            Vector2d[] points3 = spirGen.hypotrochoidPoints(30, 1, 15, 45);
            auto spir3 = new VPointsShape(points3, 150, 150, GraphicStyle(2, graphics.theme.colorAccent));

            Vector2d[] points4 = spirGen.hypotrochoidPoints(30, 1, 10, 10);
            auto spir4 = new VPointsShape(points4, 150, 150, GraphicStyle(2, graphics.theme.colorAccent));

            vectorContainers.addCreate([spir1, spir2, spir3, spir4]);

            import  deltotum.math.geometry.curves.lissajous: Lissajous;
            auto liss = new Lissajous;
            Vector2d[] lissPoints1 = liss.curve;
            auto liss1 = new VPointsShape(lissPoints1, 150, 150, GraphicStyle(2, graphics.theme.colorAccent));
            vectorContainers.addCreate(liss1);
        }
    }

}
