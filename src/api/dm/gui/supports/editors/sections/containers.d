module api.dm.gui.supports.editors.sections.containers;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.pos2.insets : Insets;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.gui.controls.containers.vbox : VBox;
import api.dm.gui.controls.containers.frame : Frame;
import api.dm.gui.controls.containers.center_box : CenterBox;
import api.dm.gui.controls.containers.border_box : BorderBox;

import api.dm.gui.controls.switches.buttons.button : Button;
import api.dm.gui.controls.switches.checks.check : Check;

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

        testCenterBox(vboxRoot);
        testBorderBox(vboxRoot);
        testCircleBox(vboxRoot);
        testFlowBox(vboxRoot);

        auto root2 = new HBox;
        root2.isBorder = true;
        root2.isAlignY = true;
        addCreate(root2);

        testScrollBox(root2);
        testSplitBox(root2);
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

    void testCenterBox(Container root)
    {
        auto cb = new CenterBox;
        cb.isBorder = true;
        root.addCreate(cb);
        cb.enablePadding;

        auto cbBtn = configureControl(new Button("Btn"));
        cbBtn.isGrow = true;
        cb.addCreate(cbBtn);
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

    void testScrollBox(Container root){
        import api.dm.gui.controls.containers.scroll_box: ScrollBox;

        auto box = new ScrollBox;
        box.resize(100, 100);
        root.addCreate(box);

        auto content = theme.circleShape(200, GraphicStyle(1, RGBA.lightblue, true, RGBA.yellowgreen));
        box.setContent(content);
    }

    void testSplitBox(Container root)
    {

        import api.dm.gui.controls.containers.splits.vsplit_box : VSplitBox;
        import api.dm.gui.controls.containers.splits.hsplit_box : HSplitBox;
        import api.dm.gui.controls.containers.vbox : VBox;

        auto split1 = new VSplitBox;
        root.addCreate(split1);

        const float rectW = 60;
        const float rectH = 80;

        auto content1 = theme.rectShape(rectW, rectH, 0, GraphicStyle(1, RGBA.greenyellow, true, RGBA
                .greenyellow));
        buildInitCreate(content1);
        auto content2 = theme.rectShape(rectW, rectH, 0, GraphicStyle(1, RGBA.salmon, true, RGBA
                .salmon));
        buildInitCreate(content2);
        auto content3 = theme.rectShape(rectW, rectH, 0, GraphicStyle(1, RGBA.salmon, true, RGBA
                .salmon));
        buildInitCreate(content3);

        split1.addContent([content1, content2, content3]);

        auto split2 = new HSplitBox;
        root.addCreate(split2);

        auto content11 = theme.rectShape(rectW, rectH, 0, GraphicStyle(1, RGBA.greenyellow, true, RGBA
                .greenyellow));
        buildInitCreate(content11);
        auto content22 = theme.rectShape(rectW, rectH, 0, GraphicStyle(1, RGBA.salmon, true, RGBA
                .salmon));
        buildInitCreate(content22);
        auto content33 = theme.rectShape(rectW, rectH, 0, GraphicStyle(1, RGBA.crimson, true, RGBA
                .crimson));
        buildInitCreate(content33);

        split2.addContent([content11, content22, content33]);

        //Complex splitting

        auto splitLeft = new VSplitBox;
        splitLeft.boundsColor = RGBA.blueviolet;
        buildInitCreate(splitLeft);
        auto contentLeftTop = theme.rectShape(rectW, rectH, 0, GraphicStyle(1, RGBA.greenyellow, true, RGBA
                .greenyellow));
        buildInitCreate(contentLeftTop);
        auto contentLeftBottom = theme.rectShape(rectW, rectH, 0, GraphicStyle(1, RGBA.salmon, true, RGBA
                .salmon));
        buildInitCreate(contentLeftBottom);

        splitLeft.addContent([contentLeftTop, contentLeftBottom]);

        auto splitCenter = new VSplitBox;
        buildInitCreate(splitCenter);
        auto contentCenterTop = theme.rectShape(rectW, rectH, 0, GraphicStyle(1, RGBA.greenyellow, true, RGBA
                .greenyellow));
        buildInitCreate(contentCenterTop);
        auto contentCenterBottom = theme.rectShape(rectW, rectH, 0, GraphicStyle(1, RGBA.salmon, true, RGBA
                .salmon));
        buildInitCreate(contentCenterBottom);

        splitCenter.boundsColor = RGBA.aliceblue;

        splitCenter.addContent([contentCenterTop, contentCenterBottom]);

        auto splitRight = new VSplitBox;
        buildInitCreate(splitRight);
        auto contentRightTop = theme.rectShape(rectW, rectH, 0, GraphicStyle(1, RGBA.greenyellow, true, RGBA
                .greenyellow));
        buildInitCreate(contentRightTop);
        auto contentRightBottom = theme.rectShape(rectW, rectH, 0,GraphicStyle(1, RGBA.salmon, true, RGBA
                .salmon));
        buildInitCreate(contentRightBottom);

        splitRight.boundsColor = RGBA.fuchsia;

        splitRight.addContent([contentRightTop, contentRightBottom]);

        auto splitMain = new HSplitBox;
        root.addCreate(splitMain);
        splitMain.addContent([splitLeft, splitCenter, splitRight]);
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
