module api.dm.gui.supports.editors.sections.containers;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.insets : Insets;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.gui.controls.containers.vbox : VBox;
import api.dm.gui.controls.containers.frame : Frame;
import api.dm.gui.controls.containers.center_box : CenterBox;
import api.dm.gui.controls.containers.border_box : BorderBox;

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

        auto hboxRoot = new HBox;
        hboxRoot.isBorder = true;
        hboxRoot.isAlignY = true;
        addCreate(hboxRoot);
        hboxRoot.enablePadding;

        testHBox(hboxRoot);

        auto vboxRoot = new HBox;
        vboxRoot.isBorder = true;
        vboxRoot.isAlignY = true;
        addCreate(vboxRoot);
        vboxRoot.enablePadding;

        testVBox(vboxRoot);

        auto frame = new Frame("Frame");
        frame.height = 100;
        //TODO bug
        //frame.isVGrow = true;
        vboxRoot.addCreate(frame);

        auto cb = new CenterBox;
        cb.isBorder = true;
        frame.addCreate(cb);
        cb.enablePadding;

        auto cbBtn = configureControl(new Button("Btn"));
        cbBtn.isGrow = true;
        cb.addCreate(cbBtn);

        testBorderBox(vboxRoot);

        testCircleBox(vboxRoot);

        testFlowBox(vboxRoot);

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

        // auto pos2Container = configureControl(new HBox(5));
        // addCreate(pos2Container);

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
        hbox1.isAlignY = true;
        hbox1.layout.isDecreaseRootSize = true;

        root.addCreate(hbox1);
        hbox1.enablePadding;

        auto checkFill = configureControl(new Check("StoE"));
        hbox1.addCreate(checkFill);
        checkFill.isOn = true;
        checkFill.onOldNewValue ~= (oldv, newv) { hbox1.isFillStartToEnd = newv; };

        auto hboxInc10 = configureControl(createButtonInc10("MT10+=10"));
        hboxInc10.marginTop = 10;
        hbox1.addCreate(hboxInc10);

        auto hboxDec10 = configureControl(createButtonDec10("MB10-=10", hboxInc10));
        hbox1.addCreate(hboxDec10);

        auto hboxMarginLeft15 = configureControl(new Check("AlignY,MLR15"));
        hboxMarginLeft15.marginLeft = 15;
        hboxMarginLeft15.marginRight = hboxMarginLeft15.marginLeft;
        hboxMarginLeft15.isOn = false;
        hboxMarginLeft15.onOldNewValue ~= (oldv, newv) { hbox1.isAlignY = newv; };
        hbox1.addCreate(hboxMarginLeft15);

        auto hboxGrow1Child = configureControl(new HBox);
        hboxGrow1Child.width = 200;
        root.addCreate(hboxGrow1Child);
        hboxGrow1Child.enablePadding;

        auto growChild = configureControl(new Button("HG"));
        growChild.isHGrow = true;
        growChild.isBackground = true;
        hboxGrow1Child.addCreate(growChild);

        auto hboxGrowChild = configureControl(new HBox);

        hboxGrowChild.width = 400;
        hboxGrowChild.isAlignY = true;
        hboxGrowChild.layout.isDecreaseRootSize = true;

        root.addCreate(hboxGrowChild);
        hboxGrowChild.enablePadding;

        auto hboxGrowChild1 = configureControl(new Button("HG1,v+=10"));
        hboxGrowChild1.onAction ~= (ref e) {
            hboxGrowChild1.height = hboxGrowChild1.height + 10;
        };
        hboxGrowChild1.isHGrow = true;
        hboxGrowChild1.isBackground = true;
        hboxGrowChild.addCreate(hboxGrowChild1);

        auto hboxGrowChild2 = configureControl(new Button("Btn,v-=10"));
        hboxGrowChild2.onAction ~= (ref e) {
            hboxGrowChild1.height = hboxGrowChild1.height - 10;
        };
        hboxGrowChild.addCreate(hboxGrowChild2);

        auto hboxGrowChild3 = configureControl(new Button("HG2"));
        hboxGrowChild3.isBackground = true;
        hboxGrowChild3.isHGrow = true;
        hboxGrowChild.addCreate(hboxGrowChild3);
    }

    void testVBox(Control root)
    {
        auto vbox1 = configureControl(new VBox);

        //TODO alignX + margin exceeding container border 
        //vbox1.isAlignX = true;

        vbox1.layout.isDecreaseRootSize = true;

        root.addCreate(vbox1);
        vbox1.enablePadding;

        auto checkFill = configureControl(new Check("StoE"));
        vbox1.addCreate(checkFill);
        checkFill.isOn = true;
        checkFill.onOldNewValue ~= (oldv, newv) { vbox1.isFillStartToEnd = newv; };

        auto vboxInc10 = configureControl(createButtonInc10("ML10+=10"));
        vboxInc10.marginLeft = 10;
        vbox1.addCreate(vboxInc10);

        auto vboxDec10 = configureControl(createButtonDec10("ML20-=10", vboxInc10));
        vboxDec10.marginLeft = 20;
        vbox1.addCreate(vboxDec10);

        auto vboxGrow1Child = configureControl(new VBox);
        vboxGrow1Child.height = 150;
        vboxGrow1Child.layout.isDecreaseRootSize = true;
        root.addCreate(vboxGrow1Child);
        vboxGrow1Child.enablePadding;

        auto growChild = configureControl(new Button("VG"));
        growChild.isGrow = true;
        growChild.isBackground = true;
        vboxGrow1Child.addCreate(growChild);

        auto vboxGrowChild = configureControl(new VBox);

        vboxGrowChild.height = 250;
        vboxGrowChild.isAlignX = true;
        vboxGrowChild.layout.isDecreaseRootSize = true;

        root.addCreate(vboxGrowChild);
        vboxGrowChild.enablePadding;

        auto vboxGrowChild1 = configureControl(new Button("G1,w+=10"));
        vboxGrowChild1.onAction ~= (ref e) {
            vboxGrowChild1.width = vboxGrowChild1.width + 10;
        };

        vboxGrowChild1.isGrow = true;
        vboxGrowChild1.isBackground = true;
        vboxGrowChild.addCreate(vboxGrowChild1);

        auto cboxGrowChild2 = configureControl(new Button("G2,w-=10"));

        cboxGrowChild2.isGrow = true;
        cboxGrowChild2.isBackground = true;
        cboxGrowChild2.onAction ~= (ref e) {
            vboxGrowChild1.width = vboxGrowChild1.width - 10;
        };

        vboxGrowChild.addCreate(cboxGrowChild2);
    }

    void testBorderBox(Container root)
    {

        auto bBox = configureControl(new BorderBox);
        root.addCreate(bBox);

        auto top = createButton("top");
        top.isHGrow = true;
        bBox.topBox.addCreate(top);

        auto left = createButton("left");
        left.isHGrow = true;
        bBox.leftBox.addCreate(left);

        auto center = createButton("center");
        center.isHGrow = true;
        bBox.centerBox.addCreate(center);

        auto right = createButton("right");
        right.isHGrow = true;
        bBox.rightBox.addCreate(right);

        auto bottom = createButton("bottom");
        bottom.isHGrow = true;
        bBox.bottomBox.addCreate(bottom);
    }

    void testCircleBox(Container root)
    {
        import api.dm.gui.controls.containers.circle_box : CircleBox;
        import api.dm.gui.controls.texts.text : Text;

        auto circleBox1 = new CircleBox;
        circleBox1.isBorder = true;
        root.addCreate(circleBox1);

        foreach (i; 1 .. 7)
        {
            import std.conv : to;

            auto btn = createButton(i.to!dstring);
            circleBox1.addCreate(btn);
            btn.rescale(0.5, 0.5);
        }
    }

    void testFlowBox(Container root)
    {
        import api.dm.gui.controls.containers.flow_box : FlowBox;

        auto flowBox1 = new FlowBox(5, 5);
        flowBox1.isBorder = true;
        flowBox1.width = 150;
        flowBox1.height = 150;
        root.addCreate(flowBox1);

        foreach (i; 1 .. 6)
        {
            import std.conv : to;

            auto btn = createButton(i.to!dstring);
            flowBox1.addCreate(btn);
        }

        auto fbox2 = new FlowBox(5, 5);
        fbox2.isBorder = true;
        fbox2.layout.isFillStartToEnd = false;
        fbox2.width = 150;
        fbox2.height = 150;
        root.addCreate(fbox2);

        foreach (i; 1 .. 6)
        {
            import std.conv : to;

            auto btn = createButton(i.to!dstring);
            fbox2.addCreate(btn);
        }
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

    Button createButtonInc10(dstring text = null, Control targetRoot = null)
    {
        auto button = createButton(text);
        auto target = targetRoot ? targetRoot : button;
        button.onAction ~= (ref e) { target.width = target.width + 10; };
        return button;
    }

    Button createButtonDec10(dstring text = null, Control targetRoot = null)
    {
        auto button = createButton(text);
        auto target = targetRoot ? targetRoot : button;
        button.onAction ~= (ref e) { target.width = target.width - 10; };
        return button;
    }

}
