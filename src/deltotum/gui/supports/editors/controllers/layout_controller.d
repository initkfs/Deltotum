module deltotum.gui.supports.editors.controllers.layout_controller;

import deltotum.gui.controls.control: Control;
import deltotum.kit.sprites.sprite: Sprite;
import deltotum.kit.graphics.colors.rgba: RGBA;
import deltotum.kit.graphics.styles.graphic_style: GraphicStyle;

/**
 * Authors: initkfs
 */
class LayoutController : Control
{
    this()
    {
        id = "deltotum_gui_editor_layout_controller";

        import deltotum.kit.sprites.layouts.vertical_layout: VerticalLayout;

        layout = new VerticalLayout(5);
        layout.isAutoResize = true;
        isBackground = false;
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
        import deltotum.gui.controls.buttons.button: Button;

        auto posContainer = new HBox;
        addCreate(posContainer);

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
        addCreate(textsContainer);

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

        addCreate(iconsContainer);
        iconsContainer.addCreate([image1, image2, image3, image4, image5]);
    }

}
