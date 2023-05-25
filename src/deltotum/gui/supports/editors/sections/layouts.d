module deltotum.gui.supports.editors.sections.layouts;

import deltotum.gui.controls.control : Control;
import deltotum.kit.sprites.sprite : Sprite;
import deltotum.kit.graphics.colors.rgba : RGBA;
import deltotum.math.geometry.insets : Insets;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

import deltotum.gui.containers.container : Container;
import deltotum.gui.containers.hbox : HBox;
import deltotum.gui.containers.vbox : VBox;

import deltotum.gui.controls.buttons.button : Button;

import std;

/**
 * Authors: initkfs
 */
class Layouts : Control
{
    this()
    {
        id = "deltotum_gui_editor_section_layouts";

        import deltotum.kit.sprites.layouts.vertical_layout : VerticalLayout;

        layout = new VerticalLayout(5);
        layout.isAutoResize = true;
        isBackground = false;
    }

    T configureControl(T)(T sprite)
    {
        if (is(T : Control))
        {
            sprite.isBorder = true;
        }
        return sprite;
    }

    Button createButton(dstring text)
    {
        auto button = configureControl(new Button(text));
        button.width = 60;
        return button;
    }

    Button createButtonInc10()
    {
        auto button = createButton("w+=10");
        button.onAction = (e) => (button.width = button.width + 10);
        return button;
    }

    Button createButtonDec10()
    {
        auto button = createButton("w-=10");
        button.onAction = (e) => (button.width = button.width - 10);
        return button;
    }

    private void testHContainers()
    {
        auto posContainer = configureControl(new HBox);
        addCreate(posContainer);

        enum prefContainerWidth = 180;
        enum maxContainerWidth = 300;

        auto posWrapper1 = configureControl(new HBox);
        posWrapper1.width = prefContainerWidth;
        posWrapper1.maxWidth = maxContainerWidth;
        posContainer.addCreate(posWrapper1);

        auto startToEndContainer = configureControl(new HBox);
        posWrapper1.addCreate(startToEndContainer);

        startToEndContainer.addCreate([createButtonInc10, createButtonDec10]);

        auto endToStartContainer = configureControl(new HBox);
        endToStartContainer.layout.isFillFromStartToEnd = false;
        endToStartContainer.width = prefContainerWidth;
        endToStartContainer.maxWidth = maxContainerWidth;
        posContainer.addCreate(endToStartContainer);

        endToStartContainer.addCreate([createButtonInc10, createButtonDec10]);

        auto fillBothContainer = configureControl(new HBox);
        fillBothContainer.width = 300;
        posContainer.addCreate(fillBothContainer);

        auto fbBtn1 = configureControl(createButton("ExpH"));
        //FIXME check Text label resizing
        fbBtn1.width = 80;
        fbBtn1.isHGrow = true;

        fillBothContainer.addCreate([
            createButtonInc10, fbBtn1, createButtonDec10
        ]);

        auto marginsContainer = configureControl(new HBox);
        marginsContainer.layout.isAlignY = false;
        posContainer.addCreate(marginsContainer);

        auto btnM1 = configureControl(new Button("t10,r15"));
        btnM1.margin = Insets(10, 15, 0, 0);

        marginsContainer.addCreate([createButtonInc10, btnM1, createButtonDec10]);

        auto marginsContainer2 = configureControl(new HBox);
        marginsContainer2.layout.isAlignY = false;
        posContainer.addCreate(marginsContainer2);

        auto btnM2 = configureControl(createButton("t5,rb15"));
        btnM2.width = 80;
        btnM2.margin = Insets(5, 15, 15, 0);

        auto btnM3 = configureControl(createButton("t15"));
        btnM3.margin = Insets(15, 0, 0, 0);

        marginsContainer2.addCreate([
                createButtonInc10, btnM2, btnM3
            ]);
    }

    private Control testVContainers()
    {
        auto posContainer = configureControl(new HBox);
        addCreate(posContainer);

        enum prefContainerHeight = 150;
        enum maxContainerHeight = 300;

        auto posWrapper1 = configureControl(new VBox);
        posWrapper1.height = prefContainerHeight;
        posWrapper1.maxHeight = maxContainerHeight;
        posContainer.addCreate(posWrapper1);

        auto startToEndContainer = configureControl(new VBox);
        posWrapper1.addCreate(startToEndContainer);

        startToEndContainer.addCreate([createButtonInc10, createButtonDec10]);

        auto endToStartContainer = configureControl(new VBox);
        endToStartContainer.width = 100;
        endToStartContainer.layout.isFillFromStartToEnd = false;
        endToStartContainer.height = prefContainerHeight;
        endToStartContainer.maxHeight = maxContainerHeight;
        posContainer.addCreate(endToStartContainer);

        auto eToSbtn1 = createButtonInc10;
        eToSbtn1.isHGrow = true;

        endToStartContainer.addCreate([eToSbtn1, createButtonDec10]);

        auto fillBothContainer = configureControl(new VBox);
        fillBothContainer.width = 100;
        fillBothContainer.height = 200;
        posContainer.addCreate(fillBothContainer);

        auto fbBtn1 = configureControl(createButton("ExpHV"));
        fbBtn1.isVGrow = true;
        fbBtn1.isHGrow = true;

        fillBothContainer.addCreate([
            createButtonInc10, fbBtn1, createButtonDec10
        ]);

        auto marginsContainer = configureControl(new VBox);
        marginsContainer.layout.isAlignX = false;
        posContainer.addCreate(marginsContainer);

        auto btnM1 = configureControl(new Button("t15,l10,b15"));
        btnM1.width = 100;
        btnM1.margin = Insets(15, 0, 15, 10);

        marginsContainer.addCreate([createButtonInc10, btnM1, createButtonDec10]);

        return posContainer;
    }

    override void create()
    {
        super.create;

        testHContainers;
        auto posVContainer = testVContainers;

        import deltotum.gui.containers.stack_box : StackBox;

        auto stackContainer = configureControl(new StackBox);
        posVContainer.addCreate(stackContainer);

        auto s1 = configureControl(new StackBox);
        s1.width = 120;
        s1.height = 120;
        stackContainer.addCreate(s1);
        auto s2 = configureControl(new StackBox);
        s2.width = 100;
        s2.height = 100;
        stackContainer.addCreate(s2);

        auto stBtn1 = createButton("ExpHV");
        stBtn1.isHGrow = true;
        stBtn1.isVGrow = true;

        s2.addCreate(stBtn1);

        import deltotum.gui.containers.border_box: BorderBox;

        auto bBox = configureControl(new BorderBox);
        posVContainer.addCreate(bBox);
        
        auto top = createButton("top");
        top.isHGrow = true;
        bBox.top.addCreate(top);

        auto left = createButton("left");
        bBox.left.addCreate(left);

        auto center = createButton("center");
        bBox.center.addCreate(center);

        auto rigth = createButton("right");
        bBox.right.addCreate(rigth);

        auto bottom = createButton("bottom");
        bottom.width = 100;
        bottom.isHGrow = true;
        bBox.bottom.addCreate(bottom);

    }

}
