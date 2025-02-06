module api.dm.gui.supports.editors.sections.containers;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.insets : Insets;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.gui.controls.containers.vbox : VBox;

import api.dm.gui.controls.switches.buttons.button : Button;
import api.dm.gui.controls.switches.checks.check : Check;

import std;

/**
 * Authors: initkfs
 */
class Containers : Control
{
    this()
    {
        id = "deltotum_gui_editor_section_containers";

        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout;
        layout.isAutoResize = true;
    }

    override void initialize()
    {
        super.initialize;
    }

    override void create()
    {
        super.create;

        testHBox(this);

        // testHContainers;
        // auto posVContainer = testVContainers;

        // import api.dm.gui.controls.containers.center_box : CenterBox;

        // auto stackContainer = configureControl(new CenterBox);
        // posVContainer.addCreate(stackContainer);

        // auto s1 = configureControl(new CenterBox);
        // s1.width = 120;
        // s1.height = 120;
        // stackContainer.addCreate(s1);
        // auto s2 = configureControl(new CenterBox);
        // s2.width = 100;
        // s2.height = 100;
        // stackContainer.addCreate(s2);

        // auto stBtn1 = createButton("ExpHV");
        // stBtn1.isHGrow = true;
        // stBtn1.isVGrow = true;

        // s2.addCreate(stBtn1);

        // import api.dm.gui.controls.containers.border_box : BorderBox;

        // auto bBox = configureControl(new BorderBox);
        // posVContainer.addCreate(bBox);

        // auto top = createButton("top");
        // top.isHGrow = true;
        // bBox.topPane.addCreate(top);

        // auto left = createButton("left");
        // bBox.leftPane.addCreate(left);

        // auto center = createButton("center");
        // bBox.centerPane.addCreate(center);

        // auto rigth = createButton("right");
        // bBox.rightPane.addCreate(rigth);

        // auto bottom = createButton("bottom");
        // bottom.width = 100;
        // bottom.isHGrow = true;
        // bBox.bottomPane.addCreate(bottom);

        // import api.dm.gui.controls.containers.flow_box : FlowBox;

        // auto flowBox1 = configureControl(new FlowBox(5, 5));
        // flowBox1.width = 200;
        // flowBox1.height = 200;
        // posVContainer.addCreate(flowBox1);

        // foreach (i; 1 .. 6)
        // {
        //     import std.conv : to;

        //     auto btn = createButton(i.to!dstring);
        //     flowBox1.addCreate(btn);
        // }

        // auto fbox2 = new FlowBox(5, 5);
        // fbox2.layout.isFillStartToEnd = false;
        // auto flowBoxEndToStart = configureControl(fbox2);
        // flowBoxEndToStart.width = 200;
        // flowBoxEndToStart.height = 200;
        // posVContainer.addCreate(flowBoxEndToStart);

        // foreach (i; 1 .. 6)
        // {
        //     import std.conv : to;

        //     auto btn = createButton(i.to!dstring);
        //     flowBoxEndToStart.addCreate(btn);
        // }

        // auto pos2Container = configureControl(new HBox(5));
        // addCreate(pos2Container);

        // import api.dm.gui.controls.containers.circle_box : CircleBox;

        // auto circleBox1 = configureControl(new CircleBox);
        // pos2Container.addCreate(circleBox1);

        // foreach (i; 1 .. 7)
        // {
        //     import std.conv : to;

        //     auto btn = createButton(i.to!dstring);
        //     circleBox1.addCreate(btn);
        // }

        // import api.dm.gui.controls.containers.splits.vsplit_box: VSplitBox;
        // import api.dm.gui.controls.containers.splits.hsplit_box: HSplitBox;
        // import api.dm.gui.controls.containers.vbox: VBox;
        // import api.dm.kit.sprites2d.textures.vectors.shapes.vconvex_polygon: VConvexPolygon;

        // auto split1 = new VSplitBox;
        // pos2Container.addCreate(split1);

        // auto content1 = new VConvexPolygon(60, 80, GraphicStyle(1, RGBA.greenyellow, true, RGBA.greenyellow), 0);
        // buildInitCreate(content1);
        // auto content2 = new VConvexPolygon(60, 80, GraphicStyle(1, RGBA.salmon, true, RGBA.salmon), 0);
        // buildInitCreate(content2);
        // auto content3 = new VConvexPolygon(60, 80, GraphicStyle(1, RGBA.salmon, true, RGBA.salmon), 0);
        // buildInitCreate(content3);

        // split1.addContent([content1, content2, content3]);

        // auto split2 = new HSplitBox;
        // pos2Container.addCreate(split2);

        // auto content11 = new VConvexPolygon(60, 80, GraphicStyle(1, RGBA.greenyellow, true, RGBA.greenyellow), 0);
        // buildInitCreate(content11);

        // auto content22 = new VConvexPolygon(60, 80, GraphicStyle(1, RGBA.salmon, true, RGBA.salmon), 0);
        // buildInitCreate(content22);

        // auto content33 = new VConvexPolygon(60, 80, GraphicStyle(1, RGBA.crimson, true, RGBA.crimson), 0);
        // buildInitCreate(content33);

        // split2.addContent([content11, content22, content33]);

        // //Complex splitting

        // auto splitLeft = new VSplitBox;
        // splitLeft.boundsColor = RGBA.blueviolet;
        // buildInitCreate(splitLeft);
        // auto contentLeftTop = new VConvexPolygon(60, 80, GraphicStyle(1, RGBA.greenyellow, true, RGBA.greenyellow), 0);
        // buildInitCreate(contentLeftTop);
        // auto contentLeftBottom = new VConvexPolygon(60, 80, GraphicStyle(1, RGBA.salmon, true, RGBA.salmon), 0);
        // buildInitCreate(contentLeftBottom);

        // splitLeft.addContent([contentLeftTop, contentLeftBottom]);

        // auto splitCenter = new VSplitBox;
        // buildInitCreate(splitCenter);
        // auto contentCenterTop = new VConvexPolygon(60, 80, GraphicStyle(1, RGBA.greenyellow, true, RGBA.greenyellow), 0);
        // buildInitCreate(contentCenterTop);
        // auto contentCenterBottom = new VConvexPolygon(60, 80, GraphicStyle(1, RGBA.salmon, true, RGBA.salmon), 0);
        // buildInitCreate(contentCenterBottom);

        // splitCenter.boundsColor = RGBA.aliceblue;

        // splitCenter.addContent([contentCenterTop, contentCenterBottom]);

        // auto splitRight = new VSplitBox;
        // buildInitCreate(splitRight);
        // auto contentRightTop = new VConvexPolygon(60, 80, GraphicStyle(1, RGBA.greenyellow, true, RGBA.greenyellow), 0);
        // buildInitCreate(contentRightTop);
        // auto contentRightBottom = new VConvexPolygon(60, 80, GraphicStyle(1, RGBA.salmon, true, RGBA.salmon), 0);
        // buildInitCreate(contentRightBottom);

        // splitRight.boundsColor = RGBA.fuchsia;

        // splitRight.addContent([contentRightTop, contentRightBottom]);

        // auto splitMain = new HSplitBox;
        // pos2Container.addCreate(splitMain);
        // splitMain.addContent([splitLeft, splitCenter, splitRight]);
    }

    void testHBox(Control root)
    {
        auto hbox1 = configureControl(new HBox);
        root.addCreate(hbox1);
        hbox1.enableInsets;

        auto hboxInc10 = configureControl(createButtonInc10);
        hbox1.addCreate(hboxInc10);

        auto hboxDec10 = configureControl(createButtonDec10);
        hbox1.addCreate(hboxDec10);

        auto hboxMarginTop10 = configureControl(new Button("MT10"));
        hboxMarginTop10.marginTop = 10;
        hbox1.addCreate(hboxMarginTop10);

        auto hboxMarginBottom10 = configureControl(new Button("MB10"));
        hboxMarginBottom10.marginBottom = 10;
        hbox1.addCreate(hboxMarginBottom10);

        auto hboxMarginLeft20 = configureControl(new Button("MLR15"));
        hboxMarginLeft20.marginLeft = 15;
        hboxMarginLeft20.marginRight = hboxMarginLeft20.marginLeft;
        hbox1.addCreate(hboxMarginLeft20);

        auto checkFill = configureControl(new Check("StoE"));
        hbox1.addCreate(checkFill);
        checkFill.isOn = true;
        checkFill.onOldNewValue ~= (oldv, newv) { hbox1.isFillStartToEnd = newv; };

        auto hboxGrow1Child = configureControl(new HBox);
        hboxGrow1Child.width = 200;
        hbox1.addCreate(hboxGrow1Child);
        hboxGrow1Child.enableInsets;

        auto growChild = configureControl(new Button("HG"));
        growChild.isHGrow = true;
        growChild.isBackground = true;
        hboxGrow1Child.addCreate(growChild);

        auto hboxGrowChild = configureControl(new HBox);
        hboxGrowChild.width = 400;
        hbox1.addCreate(hboxGrowChild);
        hboxGrowChild.enableInsets;

        auto hboxGrowChild1 = configureControl(new Button("HG1"));
        hboxGrowChild1.isHGrow = true;
        hboxGrowChild1.isBackground = true;
        hboxGrowChild.addCreate(hboxGrowChild1);

        auto hboxGrowChild2 = configureControl(new Button("Btn"));
        hboxGrowChild.addCreate(hboxGrowChild2);

        auto hboxGrowChild3 = configureControl(new Button("HG2"));
        hboxGrowChild3.isBackground = true;
        hboxGrowChild3.isHGrow = true;
        hboxGrowChild.addCreate(hboxGrowChild3);
    }

    void testvBox(Control root)
    {
        auto vboxRoot = new HBox;
        root.addCreate(vboxRoot);

        auto vbox = configureControl(new VBox);
        
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
        return button;
    }

    Button createButtonInc10()
    {
        auto button = createButton("w+=10");
        button.onAction ~= (ref e) { button.width = button.width + 10; };
        return button;
    }

    Button createButtonDec10()
    {
        auto button = createButton("w-=10");
        button.onAction ~= (ref e) { button.width = button.width - 10; };
        return button;
    }

}
