module api.dm.gui.supports.editors.sections.controls;

import api.dm.gui.controls.control : Control;
import api.dm.gui.containers.container : Container;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.gui.controls.trees.tree_item : TreeItem;
import api.dm.gui.controls.buttons.button : Button;
import api.dm.gui.containers.hbox : HBox;
import api.dm.gui.containers.vbox : VBox;
import api.dm.gui.containers.frame : Frame;
import api.dm.kit.sprites.layouts.vlayout : VLayout;

/**
 * Authors: initkfs
 */
class Controls : Control
{
    this()
    {
        id = "deltotum_gui_editor_section_controls";

        import api.dm.kit.sprites.layouts.vlayout : VLayout;

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

        auto btnContainer = new HBox(5);
        btnContainer.layout.isAlignY = true;
        rootContainer.addCreate(btnContainer);
        btnContainer.enableInsets;

        createButtons(btnContainer);
        createWindows(btnContainer);

        auto selectionContainer = new HBox;
        selectionContainer.layout.isAlignY = true;
        rootContainer.addCreate(selectionContainer);
        selectionContainer.enableInsets;

        createSelections(selectionContainer);

        createSeparators(selectionContainer);

        auto dataContainer = new HBox(5);
        dataContainer.layout.isAlignY = true;
        rootContainer.addCreate(dataContainer);

        createDataControls(dataContainer);

        createTexts(dataContainer);

        createCharts(dataContainer);

        auto progressContainer = new HBox;
        progressContainer.layout.isAlignY = true;
        rootContainer.addCreate(progressContainer);
        progressContainer.enableInsets;

        createProgressBars(progressContainer);

        // iconsContainer.isBackground = false;

        // import api.dm.kit.sprites.images.image : Image;

        // auto image1 = new Image();
        // build(image1);
        // image1.loadRaw(graphics.theme.iconData("rainy-outline"), 64, 64);
        // image1.setColor(graphics.theme.colorAccent);
    }

    void createButtons(Container root)
    {
        import api.dm.gui.controls.control : Control;

        auto btn1 = new Button("Button");
        btn1.isBackground = true;
        root.addCreate(btn1);

        import api.dm.gui.controls.buttons.round_button : RoundButton;

        auto circleBtn = new RoundButton("Button");
        circleBtn.isBackground = true;
        root.addCreate(circleBtn);

        import api.dm.gui.controls.buttons.rhombus_button : RhombusButton;

        auto rhBtn = new RhombusButton("Button");
        //rhBtn.isBackground = true;
        root.addCreate(rhBtn);

        import api.dm.gui.controls.buttons.target_button : TargetButton;

        auto targetBtn = new TargetButton("Button", 100);
        //rhBtn.isBackground = true;
        root.addCreate(targetBtn);
    }

    void createSelections(Container root)
    {
        import api.dm.gui.controls.checks.checkbox : CheckBox;
        import api.dm.gui.controls.choices.choice_box : ChoiceBox;

        import Icons = api.dm.kit.graphics.themes.icons.icon_name;

        import api.dm.gui.controls.labels.hyperlink: Hyperlink;

        auto container1 = new VBox(5);
        root.addCreate(container1);

        auto hyper1 = new Hyperlink;
        container1.addCreate(hyper1);

        import api.dm.gui.controls.labels.badge: Badge;
        import api.dm.gui.controls.texts.text: Text;

        auto tb1 = new Text("Badge");
        container1.addCreate(tb1);
        auto b1 = new Badge("10");
        tb1.addCreate(b1);

        auto checkBoxContainer = new VBox(5);
        root.addCreate(checkBoxContainer);

        auto check1 = new CheckBox("Check", Icons.bug_outline);
        checkBoxContainer.addCreate(check1);
        check1.isCheck = true;

        auto check2 = new CheckBox("Check", Icons.bug_outline);
        checkBoxContainer.addCreate(check2);
        check2.layout.isFillFromStartToEnd = false;
        check2.isCheck = true;

        auto toggleContainer = new VBox(5);
        root.addCreate(toggleContainer);

        import api.dm.gui.controls.toggles.toggle_switch : ToggleSwitch;

        auto switch1 = new ToggleSwitch("Toggle");
        toggleContainer.addCreate(switch1);

        auto switch2 = new ToggleSwitch;
        switch2.iconName = Icons.flash_outline;
        switch2.isCreateTextFactory = false;
        toggleContainer.addCreate(switch2);
        switch2.setSwitch(true);

        import api.dm.gui.controls.choices.choice_box : ChoiceBox;

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

        import api.dm.gui.controls.spinners.spinner : Spinner;

        auto spinner1 = new Spinner!int;
        root.addCreate(spinner1);

        import api.dm.gui.controls.pickers.color_picker : ColorPicker;

        auto colorPicker = new ColorPicker;
        root.addCreate(colorPicker);
    }

    void createSeparators(Container root)
    {
        import api.dm.gui.controls.separators.vseparator : VSeparator;

        auto vsep = new VSeparator;
        vsep.height = 100;
        root.addCreate(vsep);

        import api.dm.gui.controls.scrolls.hscroll : HScroll;
        import api.dm.gui.controls.scrolls.vscroll : VScroll;

        auto vScrollbar = new VScroll;
        root.addCreate(vScrollbar);

        auto hScrollbar = new HScroll;
        root.addCreate(hScrollbar);

        import api.dm.gui.controls.separators.hseparator : HSeparator;

        auto hSep = new HSeparator;
        hSep.width = 100;
        root.addCreate(hSep);
    }

    void createDataControls(Container rootContainer)
    {
        import api.dm.gui.containers.scroll_box : ScrollBox;
        import api.dm.gui.controls.texts.text : Text;

        auto sb1 = new ScrollBox(100, 100);
        rootContainer.addCreate(sb1);
        auto sbt = new Text();
        sbt.maxWidth = 200;
        sb1.setContent(sbt);
        sbt.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";

        import api.dm.gui.controls.trees.tree_list_view : TreeListView;
        import api.dm.gui.controls.trees.tree_item : TreeItem;

        auto list1 = new TreeListView!string;
        rootContainer.addCreate(list1);
        list1.fill(["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]);

        auto tree1 = new TreeListView!string;
        rootContainer.addCreate(tree1);

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
        tree1.fill(root);

        // import api.dm.gui.controls.datetimes.calendar : Calendar;

        // auto cal1 = new Calendar;
        // rootContainer.addCreate(cal1);

        // import api.dm.gui.controls.pickers.time_picker : TimePicker;

        // auto time1 = new TimePicker;
        // rootContainer.addCreate(time1);

        import api.dm.gui.controls.clocks.analog_clock: AnalogClock;
        auto clock1 = new AnalogClock;
        rootContainer.addCreate(clock1);
    }

    void createCharts(Container root)
    {
        import api.dm.gui.controls.charts.linear_chart : LinearChart;

        auto linearChart = new LinearChart;
        root.addCreate(linearChart);

        import std.range : iota;
        import std.array : array;
        import std.algorithm.iteration : map;
        import std.math.trigonometry : sin;

        double[] x = iota(1, 10, 0.01).array;
        double[] y = x.map!sin.array;

        linearChart.data(x, y);
    }

    private void createWindows(Container root)
    {
        import api.dm.gui.controls.buttons.button : Button;
        import api.dm.gui.controls.checks.checkbox : CheckBox;
        import IconName = api.dm.kit.graphics.themes.icons.icon_name;

        import api.dm.gui.controls.control : Control;

        auto winMin = new Button("Minimize", IconName.arrow_down_outline);
        root.addCreate(winMin);
        winMin.onAction = (ref e) {
            //TODO false,false 
            logger.trace("Window is minimized before request: ", window.isMinimized);
            window.minimize;
            logger.trace("Window is minimized after request: ", window.isMinimized);
        };

        auto winMax = new Button("Maximize", IconName.arrow_up_outline);
        root.addCreate(winMax);
        winMax.layout.isFillFromStartToEnd = false;
        winMax.onAction = (ref e) {
            logger.trace("Window is maximized before request: ", window.isMaximized);
            window.maximize;
            logger.trace("Window is maximized after request: ", window.isMaximized);
        };

        import api.dm.kit.sprites.layouts.vlayout : VLayout;

        auto winRestore = new Button("Restore", IconName.push_outline);
        winRestore.actionType = Control.ActionType.success;
        winRestore.layout = new VLayout(5);
        winRestore.layout.isAutoResizeAndAlignOne = true;
        winRestore.layout.isAlignX = true;

        root.addCreate(winRestore);
        winRestore.onAction = (ref e) { window.restore; };

        auto winFull = new Button("Fullscreen", IconName.expand_outline);
        winFull.actionType = Control.ActionType.danger;
        winFull.layout = new VLayout(5);
        winFull.layout.isAutoResizeAndAlignOne = true;
        winFull.layout.isAlignX = true;
        winFull.layout.isFillFromStartToEnd = false;
        root.addCreate(winFull);
        winFull.onAction = (ref e) {
            auto oldValue = window.isFullScreen;
            logger.trace("Window fullscreen before request: ", oldValue);
            window.isFullScreen = !oldValue;
            logger.trace("Window fullscreen after request: ", window.isFullScreen);
        };

        auto winDec = new Button("Decoration", IconName.image_outline);
        winDec.actionType = Control.ActionType.warning;
        root.addCreate(winDec);
        winDec.onAction = (ref e) {
            auto oldValue = window.isDecorated;
            logger.trace("Window decorated before request: ", oldValue);
            window.isDecorated = !oldValue;
            logger.trace("Window fullscreen after request: ", window.isDecorated);
        };

        auto winResize = new Button("Resizable", IconName.resize_outline);
        root.addCreate(winResize);
        winResize.onAction = (ref e) {
            auto oldValue = window.isResizable;
            logger.trace("Window resizable before request: ", oldValue);
            window.isResizable = !oldValue;
            logger.trace("Window resizable after request: ", window.isResizable);
        };
    }

    private void createTexts(Container root)
    {
        import api.dm.gui.controls.texts.text : Text;
        import api.dm.gui.controls.texts.text_view : TextView;
        import api.dm.gui.controls.texts.text_area : TextArea;

        import api.dm.gui.controls.expanders.expander : Expander, ExpanderPosition;

        auto exp = new Expander;
        exp.expandPosition = ExpanderPosition.top;
        root.addCreate(exp);
        //exp.close;

        auto t1 = new Text("Коммодор никак не мог отделаться от ощущения чудовищных перегрузок и невыносимой яркости освещения. Но он по-прежнему сидел в своем отсеке, хотя рука его еще лежала на клавише «Уничтожение»...");
        t1.isEditable = true;
        t1.maxWidth = 350;
        t1.isBorder = true;
        exp.contentContainer.addCreate(t1);
        t1.enableInsets;
    }

    private void createProgressBars(Container root)
    {
        import api.dm.gui.controls.progress.radial_progress_bar : RadialProgressBar;

        auto rb1 = new RadialProgressBar;
        rb1.isPercentMode = true;
        root.addCreate(rb1);
        rb1.progress = 0.6;

        import api.dm.gui.controls.gauges.hlinear_gauge : HLinearGauge;

        auto ling1 = new HLinearGauge;
        //ling1.isBorder = true;
        root.addCreate(ling1);
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
