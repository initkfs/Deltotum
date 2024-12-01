module api.dm.gui.supports.editors.sections.layouts;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.insets : Insets;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

import api.dm.gui.containers.container : Container;
import api.dm.gui.containers.hbox : HBox;
import api.dm.gui.containers.vbox : VBox;

import api.dm.gui.controls.switches.buttons.button : Button;

import std;

/**
 * Authors: initkfs
 */
class Layouts : Control
{
    this()
    {
        id = "deltotum_gui_editor_section_layouts";

        import api.dm.kit.sprites.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout;
        layout.isAutoResize = true;
        isBackground = false;
    }

    override void initialize()
    {
        super.initialize;
        enablePadding;
    }

    T configureControl(T)(T sprite)
    {
        static if (is(T : Control))
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
        button.onAction ~= (ref e){
            button.width = button.width + 10;
        };
        return button;
    }

    Button createButtonDec10()
    {
        auto button = createButton("w-=10");
        button.onAction ~= (ref e){
            button.width = button.width - 10;
        };
        return button;
    }

    private void testHContainers()
    {
        auto posContainer = configureControl(new HBox);
        addCreate(posContainer);

        enum prefContainerWidth = 180;
        enum maxContainerWidth = 300;

        auto btn = createButton("Btn");
        btn.isHGrow = true;
        btn.id = "btn";
        posContainer.addCreate(btn);
        posContainer.enableInsets;

        auto posWrapper1 = configureControl(new HBox);
        posWrapper1.width = prefContainerWidth;
        posWrapper1.maxWidth = maxContainerWidth;
        posContainer.addCreate(posWrapper1);
        posWrapper1.enableInsets;

        auto startToEndContainer = configureControl(new HBox);
        posWrapper1.addCreate(startToEndContainer);
        startToEndContainer.enableInsets;

        startToEndContainer.addCreate([createButtonInc10, createButtonDec10]);

        auto endToStartContainer = configureControl(new HBox);
        endToStartContainer.layout.isFillFromStartToEnd = false;
        endToStartContainer.width = prefContainerWidth;
        endToStartContainer.maxWidth = maxContainerWidth;
        posContainer.addCreate(endToStartContainer);
        endToStartContainer.enableInsets;

        endToStartContainer.addCreate([createButtonInc10, createButtonDec10]);

        auto fillBothContainer = configureControl(new HBox);
        fillBothContainer.width = 300;
        posContainer.addCreate(fillBothContainer);
        fillBothContainer.enableInsets;

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
        marginsContainer.enableInsets;

        auto btnM1 = configureControl(new Button("t10,r15"));
        btnM1.margin = Insets(10, 15, 0, 0);

        marginsContainer.addCreate([createButtonInc10, btnM1, createButtonDec10]);

        auto marginsContainer2 = configureControl(new HBox);
        marginsContainer2.layout.isAlignY = false;
        posContainer.addCreate(marginsContainer2);
        marginsContainer2.enableInsets;

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
        posContainer.enableInsets;

        enum prefContainerHeight = 150;
        enum maxContainerHeight = 300;

        auto posWrapper1 = configureControl(new VBox);
        posWrapper1.height = prefContainerHeight;
        posWrapper1.maxHeight = maxContainerHeight;
        posContainer.addCreate(posWrapper1);
        posWrapper1.enableInsets;

        auto startToEndContainer = configureControl(new VBox);
        posWrapper1.addCreate(startToEndContainer);
        startToEndContainer.enableInsets;

        startToEndContainer.addCreate([createButtonInc10, createButtonDec10]);

        auto endToStartContainer = configureControl(new VBox);
        endToStartContainer.width = 100;
        endToStartContainer.layout.isFillFromStartToEnd = false;
        endToStartContainer.height = prefContainerHeight;
        endToStartContainer.maxHeight = maxContainerHeight;
        posContainer.addCreate(endToStartContainer);
        endToStartContainer.enableInsets;

        auto eToSbtn1 = createButtonInc10;
        eToSbtn1.isHGrow = true;

        endToStartContainer.addCreate([eToSbtn1, createButtonDec10]);

        auto fillBothContainer = configureControl(new VBox);
        fillBothContainer.width = 100;
        fillBothContainer.height = 200;
        posContainer.addCreate(fillBothContainer);
        fillBothContainer.enableInsets;

        auto fbBtn1 = configureControl(createButton("ExpHV"));
        fbBtn1.isVGrow = true;
        fbBtn1.isHGrow = true;

        fillBothContainer.addCreate([
            createButtonInc10, fbBtn1, createButtonDec10
        ]);

        auto marginsContainer = configureControl(new VBox);
        marginsContainer.layout.isAlignX = false;
        posContainer.addCreate(marginsContainer);
        marginsContainer.enableInsets;

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

        import api.dm.gui.containers.stack_box : StackBox;

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

        import api.dm.gui.containers.border_box : BorderBox;

        auto bBox = configureControl(new BorderBox);
        posVContainer.addCreate(bBox);

        auto top = createButton("top");
        top.isHGrow = true;
        bBox.topPane.addCreate(top);

        auto left = createButton("left");
        bBox.leftPane.addCreate(left);

        auto center = createButton("center");
        bBox.centerPane.addCreate(center);

        auto rigth = createButton("right");
        bBox.rightPane.addCreate(rigth);

        auto bottom = createButton("bottom");
        bottom.width = 100;
        bottom.isHGrow = true;
        bBox.bottomPane.addCreate(bottom);

        import api.dm.gui.containers.flow_box : FlowBox;

        auto flowBox1 = configureControl(new FlowBox(5, 5));
        flowBox1.width = 200;
        flowBox1.height = 200;
        posVContainer.addCreate(flowBox1);

        foreach (i; 1 .. 6)
        {
            import std.conv : to;

            auto btn = createButton(i.to!dstring);
            flowBox1.addCreate(btn);
        }

        auto fbox2 = new FlowBox(5, 5);
        fbox2.layout.isFillFromStartToEnd = false;
        auto flowBoxEndToStart = configureControl(fbox2);
        flowBoxEndToStart.width = 200;
        flowBoxEndToStart.height = 200;
        posVContainer.addCreate(flowBoxEndToStart);

        foreach (i; 1 .. 6)
        {
            import std.conv : to;

            auto btn = createButton(i.to!dstring);
            flowBoxEndToStart.addCreate(btn);
        }

        auto pos2Container = configureControl(new HBox(5));
        addCreate(pos2Container);

        import api.dm.gui.containers.circle_box : CircleBox;

        auto circleBox1 = configureControl(new CircleBox);
        pos2Container.addCreate(circleBox1);

        foreach (i; 1 .. 7)
        {
            import std.conv : to;

            auto btn = createButton(i.to!dstring);
            circleBox1.addCreate(btn);
        }

        import api.dm.gui.containers.vsplit_box: VSplitBox;
        import api.dm.gui.containers.hsplit_box: HSplitBox;
        import api.dm.gui.containers.vbox: VBox;
        import api.dm.kit.sprites.sprites2d.textures.vectors.shapes.vconvex_polygon: VConvexPolygon;

        auto split1 = new VSplitBox;
        pos2Container.addCreate(split1);
    
        auto content1 = new VConvexPolygon(60, 80, GraphicStyle(1, RGBA.greenyellow, true, RGBA.greenyellow), 0);
        buildInitCreate(content1);
        auto content2 = new VConvexPolygon(60, 80, GraphicStyle(1, RGBA.salmon, true, RGBA.salmon), 0);
        buildInitCreate(content2);
        auto content3 = new VConvexPolygon(60, 80, GraphicStyle(1, RGBA.salmon, true, RGBA.salmon), 0);
        buildInitCreate(content3);

        split1.addContent([content1, content2, content3]);

        auto split2 = new HSplitBox;
        pos2Container.addCreate(split2);
    
        auto content11 = new VConvexPolygon(60, 80, GraphicStyle(1, RGBA.greenyellow, true, RGBA.greenyellow), 0);
        buildInitCreate(content11);

        auto content22 = new VConvexPolygon(60, 80, GraphicStyle(1, RGBA.salmon, true, RGBA.salmon), 0);
        buildInitCreate(content22);

        auto content33 = new VConvexPolygon(60, 80, GraphicStyle(1, RGBA.crimson, true, RGBA.crimson), 0);
        buildInitCreate(content33);

        split2.addContent([content11, content22, content33]);

        //Complex splitting

        auto splitLeft = new VSplitBox;
        splitLeft.boundsColor = RGBA.blueviolet;
        buildInitCreate(splitLeft);
        auto contentLeftTop = new VConvexPolygon(60, 80, GraphicStyle(1, RGBA.greenyellow, true, RGBA.greenyellow), 0);
        buildInitCreate(contentLeftTop);
        auto contentLeftBottom = new VConvexPolygon(60, 80, GraphicStyle(1, RGBA.salmon, true, RGBA.salmon), 0);
        buildInitCreate(contentLeftBottom);

        splitLeft.addContent([contentLeftTop, contentLeftBottom]);

        auto splitCenter = new VSplitBox;
        buildInitCreate(splitCenter);
        auto contentCenterTop = new VConvexPolygon(60, 80, GraphicStyle(1, RGBA.greenyellow, true, RGBA.greenyellow), 0);
        buildInitCreate(contentCenterTop);
        auto contentCenterBottom = new VConvexPolygon(60, 80, GraphicStyle(1, RGBA.salmon, true, RGBA.salmon), 0);
        buildInitCreate(contentCenterBottom);

        splitCenter.boundsColor = RGBA.aliceblue;

        splitCenter.addContent([contentCenterTop, contentCenterBottom]);

        auto splitRight = new VSplitBox;
        buildInitCreate(splitRight);
        auto contentRightTop = new VConvexPolygon(60, 80, GraphicStyle(1, RGBA.greenyellow, true, RGBA.greenyellow), 0);
        buildInitCreate(contentRightTop);
        auto contentRightBottom = new VConvexPolygon(60, 80, GraphicStyle(1, RGBA.salmon, true, RGBA.salmon), 0);
        buildInitCreate(contentRightBottom);

        splitRight.boundsColor = RGBA.fuchsia;

        splitRight.addContent([contentRightTop, contentRightBottom]);

        auto splitMain = new HSplitBox;
        pos2Container.addCreate(splitMain);
        splitMain.addContent([splitLeft, splitCenter, splitRight]);
    }

}
