module deltotum.gui.supports.editors.sections.controls;

import deltotum.gui.controls.control : Control;
import deltotum.gui.containers.container : Container;
import deltotum.kit.sprites.sprite : Sprite;
import deltotum.kit.graphics.colors.rgba : RGBA;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.gui.controls.data.tree_table_view : TreeItem;
import deltotum.gui.controls.buttons.button : Button;
import deltotum.gui.containers.hbox : HBox;
import deltotum.gui.containers.vbox : VBox;
import deltotum.gui.containers.frame : Frame;
import deltotum.kit.sprites.layouts.vlayout : VLayout;

/**
 * Authors: initkfs
 */
class Controls : Control
{
    this()
    {
        id = "deltotum_gui_editor_section_controls";

        import deltotum.kit.sprites.layouts.vlayout : VLayout;

        layout = new VLayout(5);
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
        if (is(T : Control))
        {
            sprite.isBorder = true;
        }
        return sprite;
    }

    override void create()
    {
        super.create;

        auto rootContainer = new VBox;
        rootContainer.width = 500;
        rootContainer.height = 400;
        rootContainer.layout.isAlignY = true;
        addCreate(rootContainer);

        auto btnContainer = new HBox;
        btnContainer.layout.isAlignY = true;
        rootContainer.addCreate(btnContainer);
        btnContainer.enableInsets;

        createButtons(btnContainer);

        auto selectionContainer = new HBox;
        selectionContainer.layout.isAlignY = true;
        rootContainer.addCreate(selectionContainer);
        selectionContainer.enableInsets;

        createSelections(selectionContainer);

        createSeparators(selectionContainer);

        auto dataContainer = new HBox;
        dataContainer.layout.isAlignY = true;
        rootContainer.addCreate(dataContainer);

        createDataControls(dataContainer);

        // import deltotum.gui.controls.charts.linear_chart: LinearChart;
        // auto linearChart = new LinearChart;
        // rootContainer.addCreate(linearChart);

        // import std.range: iota;
        // import std.array: array;
        // import std.algorithm.iteration: map;
        // import std.math.trigonometry: sin;

        // double[] x = iota(1, 10, 0.01).array;
        // double[] y = x.map!sin.array;

        // linearChart.data(x, y);

        // import deltotum.gui.containers.scroll_box : ScrollBox;

        // auto scrollBox = new ScrollBox;
        // scrollBox.isBorder = true;
        // scrollBox.width = 200;
        // scrollBox.height = 200;
        // container3.addCreate(scrollBox);
        // import deltotum.gui.containers.vbox : VBox;

        // auto vbox = new VBox;
        // vbox.isBorder = true;
        // vbox.resize(400, 400);
        // import deltotum.gui.controls.buttons.button : Button;

        // scrollBox.setContent(vbox);

        // foreach (i; 0 .. 10)
        // {
        //     vbox.addCreate(new Button);
        // }

        // iconsContainer.isBackground = false;

        // import deltotum.kit.sprites.images.image : Image;

        // auto image1 = new Image();
        // build(image1);
        // image1.loadRaw(graphics.theme.iconData("rainy-outline"), 64, 64);
        // image1.setColor(graphics.theme.colorAccent);

        // auto image2 = new Image();
        // build(image2);
        // image2.loadRaw(graphics.theme.iconData("thunderstorm-outline"), 64, 64);
        // image2.setColor(graphics.theme.colorAccent);

        // auto image3 = new Image();
        // build(image3);
        // image3.loadRaw(graphics.theme.iconData("sunny-outline"), 64, 64);
        // image3.setColor(graphics.theme.colorAccent);

        // auto image4 = new Image();
        // build(image4);
        // image4.loadRaw(graphics.theme.iconData("cloudy-night-outline"), 64, 64);
        // image4.setColor(graphics.theme.colorAccent);

        // auto image5 = new Image();
        // build(image5);
        // image5.loadRaw(graphics.theme.iconData("flash-outline"), 64, 64);
        // image5.setColor(graphics.theme.colorAccent);

        // addCreate(iconsContainer);
        // iconsContainer.addCreate([image1, image2, image3, image4, image5]);

    }

    void createButtons(Container root)
    {
        import deltotum.gui.controls.control : Control;

        auto btn1 = new Button("Button");
        btn1.isBackground = true;
        root.addCreate(btn1);

        auto btns = new Button("Success");
        btns.actionType = Control.ActionType.success;
        root.addCreate(btns);

        auto btnw = new Button("Warning");
        btnw.actionType = Control.ActionType.warning;
        root.addCreate(btnw);

        auto btnd = new Button("Danger");
        btnd.actionType = Control.ActionType.danger;
        root.addCreate(btnd);
    }

    void createSelections(Container root)
    {
        import deltotum.gui.controls.choices.toggle_switch : ToggleSwitch;
        import deltotum.gui.controls.choices.checkbox : CheckBox;
        import deltotum.gui.controls.choices.choice_box : ChoiceBox;

        auto switch1 = new ToggleSwitch;
        root.addCreate(switch1);

        import deltotum.gui.controls.choices.checkbox : CheckBox;

        auto check1 = new CheckBox;
        root.addCreate(check1);
        check1.label.text = "Check";

        import deltotum.gui.controls.choices.choice_box : ChoiceBox;

        dstring[] choiceItems = [
            "label1", "label2", "string1", "string2"
        ];

        auto chContainer1 = new VBox;
        root.addCreate(chContainer1);
        chContainer1.enableInsets;

        auto choice1 = new ChoiceBox;
        chContainer1.addCreate(choice1);
        choice1.fill(choiceItems);

        auto choice22 = new ChoiceBox;
        choice22.layout.isFillFromStartToEnd = false;
        chContainer1.addCreate(choice22);
        choice22.fill(choiceItems);

        auto choice2 = new ChoiceBox;
        choice2.isCreateStepSelection = true;
        root.addCreate(choice2);
        choice2.fill(choiceItems);

        auto choice3 = new ChoiceBox;
        auto vlayout = new VLayout(2);
        vlayout.isAutoResize = true;
        vlayout.isAlignX = true;
        choice3.layout = vlayout;
        choice3.isCreateStepSelection = true;
        root.addCreate(choice3);
        choice3.fill(choiceItems);

        import deltotum.gui.controls.pickers.color_picker : ColorPicker;

        auto colorPicker = new ColorPicker;
        root.addCreate(colorPicker);
    }

    void createSeparators(Container root)
    {
        import deltotum.gui.controls.separators.vseparator : VSeparator;

        auto vsep = new VSeparator;
        vsep.height = 100;
        root.addCreate(vsep);

        import deltotum.gui.controls.sliders.hslider : HSlider;
        import deltotum.gui.controls.sliders.vslider : VSlider;

        auto vScrollbar = new VSlider;
        root.addCreate(vScrollbar);

        auto hScrollbar = new HSlider;
        root.addCreate(hScrollbar);

        import deltotum.gui.controls.separators.hseparator : HSeparator;

        auto hSep = new HSeparator;
        hSep.width = 100;
        root.addCreate(hSep);
    }

    void createDataControls(Container rootContainer)
    {

        import deltotum.gui.controls.data.tree_table_view : TreeTableView, TreeItem;

        auto tree1 = new TreeTableView!string;
        tree1.resize(150, 150);
        auto root = new TreeItem!string("root");
        auto child = new TreeItem!string("child1");
        auto child2 = new TreeItem!string("child2");

        child.children ~= child2;
        root.children ~= child;

        import std.conv : to;

        foreach (i; 0 .. 10)
        {
            root.children ~= new TreeItem!string(i.to!string);
        }

        rootContainer.addCreate(tree1);
        tree1.fill(root);
    }

    private TreeItem!Sprite buildSpriteTree(Sprite root)
    {

        auto node = new TreeItem!Sprite(root);

        foreach (ch; root.children)
        {
            auto childNode = buildSpriteTree(ch);
            node.children ~= childNode;
        }

        return node;
    }

}
