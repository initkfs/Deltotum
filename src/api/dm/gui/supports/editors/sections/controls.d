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
import api.dm.gui.controls.carousels.carousel;

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

        auto selectionContainer = new HBox(5);
        selectionContainer.layout.isAlignY = true;
        rootContainer.addCreate(selectionContainer);

        createSelections(selectionContainer);

        // createSeparators(selectionContainer);

        // auto dataContainer = new HBox(5);
        // dataContainer.layout.isAlignY = true;
        // rootContainer.addCreate(dataContainer);

        //createDataControls(dataContainer);

        //createTexts(dataContainer);

        // auto chartContainer = new HBox(5);
        // chartContainer.layout.isAlignY = true;
        // rootContainer.addCreate(chartContainer);

        // createCharts(chartContainer);

        // auto progressContainer = new HBox;
        // progressContainer.layout.isAlignY = true;
        // rootContainer.addCreate(progressContainer);
        // progressContainer.enableInsets;

        // createProgressBars(progressContainer);

        // iconsContainer.isBackground = false;

        // import api.dm.kit.sprites.images.image : Image;

        // auto image1 = new Image();
        // build(image1);
        // image1.loadRaw(theme.iconData("rainy-outline"), 64, 64);
        // image1.setColor(theme.colorAccent);
    }

    void createButtons(Container root)
    {
        import api.dm.gui.controls.control : Control;
        import api.dm.gui.containers.frame : Frame;

        auto btnFrame = new Frame("Buttons");
        root.addCreate(btnFrame);
        btnFrame.isVGrow = true;

        import api.dm.gui.containers.vbox : VBox;
        import api.dm.gui.containers.hbox : HBox;

        auto btnRoot2 = new VBox(5);
        btnFrame.addCreate(btnRoot2);
        btnRoot2.layout.isDecreaseRootWidth = true;

        auto btn1 = new Button("Button");
        btnRoot2.addCreate(btn1);

        auto btn2 = new Button("Button");
        btn2.isBackground = true;
        btnRoot2.addCreate(btn2);

        auto btnRoot3 = new HBox(5);
        btnFrame.addCreate(btnRoot3);

        import api.dm.gui.controls.buttons.round_button : RoundButton;

        auto circleBtn = new RoundButton("Button");
        btnRoot3.addCreate(circleBtn);

        import api.dm.gui.controls.buttons.poly_button : PolyButton;

        import api.dm.kit.sprites.tweens : PauseTween;

        auto regBtn = new PolyButton("Button");
        btnRoot3.addCreate(regBtn);

        auto recreateTween = new PauseTween(100);
        regBtn.addCreate(recreateTween);

        size_t sides = 3;

        recreateTween.onStop ~= () {
            regBtn.sides = sides;
            regBtn.recreate;
            regBtn.recreateContent;
            sides++;
        };

        regBtn.onAction ~= (ref e) {
            if (!recreateTween.isRunning)
            {
                recreateTween.run;
            }
        };
    }

    void createDialogs(Container root)
    {
        import api.dm.gui.containers.frame : Frame;
        import api.dm.gui.containers.vbox : VBox;

        auto frame = new Frame("Dialogs");
        frame.isVGrow = true;
        root.addCreate(frame);

        auto root1 = new VBox(5);
        frame.addCreate(root1);
        auto root2 = new HBox(5);
        root1.addCreate(root2);
        auto root3 = new HBox(5);
        root1.addCreate(root3);

        auto btnInfo = new Button("Info", (ref e) {
            interact.dialog.showInfo("Info!");
        });
        root2.addCreate(btnInfo);

        auto btnError = new Button("Error", (ref e) {
            interact.dialog.showError("Error!");
        });
        root2.addCreate(btnError);

        auto btnQuestion = new Button("Question", (ref e) {
            interact.dialog.showQuestion("Question");
        });
        root2.addCreate(btnQuestion);

        auto popBtn = new Button("Popup", (ref e) {
            import std.conv : to;
            import std.datetime;

            auto curt = Clock.currTime();
            interact.popup.notify("Popup: " ~ curt.toISOExtString.to!dstring);
        });
        root3.addCreate(popBtn);

        auto popUrgBtn = new Button("Urgent", (ref e) {
            import std.conv : to;
            import std.datetime;

            auto curt = Clock.currTime();
            interact.popup.urgent("Popup: " ~ curt.toISOExtString.to!dstring);
        });
        root3.addCreate(popUrgBtn);
    }

    void createSelections(Container root)
    {
        import api.dm.gui.controls.switches.switch_group : SwitchGroup;
        import api.dm.gui.controls.switches.checks.check : Check;
        import api.dm.gui.controls.choices.choice_box : ChoiceBox;
        import Icons = api.dm.gui.themes.icons.icon_name;
        import api.dm.kit.sprites.layouts.vlayout : VLayout;
        import api.dm.kit.sprites.layouts.hlayout : HLayout;
        import api.dm.gui.controls.switches.toggle_buttons.toggle_button : ToggleButton;

        auto toggleBtnContainer = new SwitchGroup;
        toggleBtnContainer.layout = new VLayout(5);
        toggleBtnContainer.layout.isAutoResize = true;
        root.addCreate(toggleBtnContainer);

        import api.dm.kit.graphics.styles.default_style : DefaultStyle;

        auto tbtn1 = new ToggleButton(null, Icons.close_outline);
        tbtn1.styleId = DefaultStyle.warning;
        tbtn1.isOn = true;
        toggleBtnContainer.addCreate(tbtn1);

        auto tbtn2 = new ToggleButton(null, Icons.apps_outline);
        tbtn2.styleId = DefaultStyle.danger;
        toggleBtnContainer.addCreate(tbtn2);

        auto checkBoxContainer = new SwitchGroup;
        checkBoxContainer.layout = new VLayout(5);
        checkBoxContainer.layout.isAutoResize = true;
        root.addCreate(checkBoxContainer);

        auto check1 = new Check("Check1", Icons.bug_outline);
        checkBoxContainer.addCreate(check1);

        auto check2 = new Check("Check2", Icons.bug_outline);
        check2.isBorder = true;
        checkBoxContainer.addCreate(check2);
        check2.layout.isFillFromStartToEnd = false;
        check2.isOn = true;

        auto toggleContainer = new SwitchGroup;
        toggleContainer.layout = new VLayout(5);
        toggleContainer.layout.isAutoResize = true;
        root.addCreate(toggleContainer);

        import api.dm.gui.controls.switches.toggles.toggle_switch : ToggleSwitch;
        import api.math.orientation : Orientation;

        auto switch1 = new ToggleSwitch("Toggle");
        toggleContainer.addCreate(switch1);
        switch1.isOn = true;

        auto switch2 = new ToggleSwitch(null, Icons.flash_outline);
        switch2.isBorder = true;
        toggleContainer.addCreate(switch2);

        auto htoggleContainer = new SwitchGroup;
        htoggleContainer.layout = new HLayout(5);
        htoggleContainer.layout.isAutoResize = true;
        root.addCreate(htoggleContainer);

        auto switch1h = new ToggleSwitch(null, Icons.analytics_outline, Orientation.vertical);
        htoggleContainer.addCreate(switch1h);
        switch1h.isOn = true;
        switch1h.isSwitchContent = true;

        auto switch2h = new ToggleSwitch(null, Icons.apps_outline, Orientation.vertical);
        switch2h.isSwitchContent = true;
        htoggleContainer.addCreate(switch2h);

        // import api.dm.gui.controls.choices.choice_box : ChoiceBox;

        // dstring[] choiceItems = [
        //     "label1", "label2", "string1", "string2"
        // ];

        // auto chContainer1 = new VBox;
        // root.addCreate(chContainer1);
        // chContainer1.enableInsets;

        // auto choice1 = new ChoiceBox;
        // chContainer1.addCreate(choice1);
        // choice1.fill(choiceItems);

        // auto choice22 = new ChoiceBox;
        // choice22.layout.isFillFromStartToEnd = false;
        // chContainer1.addCreate(choice22);
        // choice22.fill(choiceItems);

        // auto choice2 = new ChoiceBox;
        // choice2.isCreateStepSelection = true;
        // root.addCreate(choice2);
        // choice2.fill(choiceItems);

        // auto choice3 = new ChoiceBox;
        // auto vlayout = new VLayout(2);
        // vlayout.isAutoResize = true;
        // vlayout.isAlignX = true;
        // choice3.layout = vlayout;
        // choice3.isCreateStepSelection = true;
        // root.addCreate(choice3);
        // choice3.fill(choiceItems);

        // import api.dm.gui.controls.spinners.spinner : Spinner;

        // auto spinner1 = new Spinner!int;
        // root.addCreate(spinner1);

        // import api.dm.gui.controls.pickers.color_picker : ColorPicker;

        // auto colorPicker = new ColorPicker;
        // root.addCreate(colorPicker);
    }

    void createSeparators(Container root)
    {
        import api.dm.gui.controls.separators.vseparator : VSeparator;

        auto vsep = new VSeparator;
        vsep.height = 100;
        root.addCreate(vsep);

        import api.dm.gui.controls.scrolls.hscroll : HScroll;
        import api.dm.gui.controls.scrolls.vscroll : VScroll;
        import api.dm.gui.controls.scrolls.radial_scroll : RadialScroll;

        auto vScrollbar = new VScroll;
        root.addCreate(vScrollbar);

        auto hScrollbar = new HScroll;
        root.addCreate(hScrollbar);

        auto rScroll = new RadialScroll;
        root.addCreate(rScroll);

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

        import api.dm.gui.controls.paginations.pagination : Pagination;
        import api.dm.gui.controls.texts.text : Text;
        import api.dm.gui.containers.vbox : VBox;

        import api.dm.gui.controls.carousels.carousel : Carousel;

        auto paginationRoot = new VBox(3);
        paginationRoot.layout.isAlignX = true;
        rootContainer.addCreate(paginationRoot);

        import api.dm.kit.sprites.textures.vectors.shapes.vconvex_polygon : VConvexPolygon;
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
        import api.dm.kit.graphics.colors.rgba : RGBA;

        auto image1 = new VConvexPolygon(50, 50, GraphicStyle(1, RGBA.lightblue, true, RGBA.yellow));
        auto image2 = new VConvexPolygon(50, 50, GraphicStyle(1, RGBA.lightblue, true, RGBA.green));
        auto image3 = new VConvexPolygon(50, 50, GraphicStyle(1, RGBA.lightblue, true, RGBA.red));
        auto image4 = new VConvexPolygon(50, 50, GraphicStyle(1, RGBA.lightblue, true, RGBA.blue));
        auto image5 = new VConvexPolygon(50, 50, GraphicStyle(1, RGBA.lightblue, true, RGBA.orange));

        auto paginationContent = new Carousel([
            image1, image2, image3, image4, image5
        ]);
        paginationRoot.addCreate(paginationContent);

        auto pagination = new Pagination;
        pagination.pageFactory = (size_t pageIndex) { import std.conv : to; };
        paginationRoot.addCreate(pagination);

        import api.dm.gui.controls.clocks.analog_clock : AnalogClock;

        auto clock1 = new AnalogClock;
        rootContainer.addCreate(clock1);
    }

    void createCharts(Container root)
    {
        import api.dm.gui.controls.charts.lines.linear_chart : LinearChart;

        auto linearChart = new LinearChart(200, 200);
        root.addCreate(linearChart);

        import std.range : iota;
        import std.array : array;
        import std.algorithm.iteration : map;
        import std.math.trigonometry : sin;

        //double[] x = iota(1, 10, 0.01).array;
        //double[] y = x.map!sin.array;

        double[] x = [0, 1, 2, 3, 7];
        double[] y = [0, 1, 2, 3, 7];

        linearChart.data(x, y);

        import api.dm.gui.controls.charts.bars.bar_chart : BarChart, BarSet;

        auto bar1 = new BarChart;
        root.addCreate(bar1);

        BarSet[] barSets = [
            {"set1", [{"Item1", 10}, {"Item1", 35}, {"Item1", 5}]},
            {"set2", [{"Item1", 10}, {"Item1", 35}, {"Item1", 5}]}
        ];

        bar1.data = barSets;

        import api.dm.gui.controls.charts.pies.pie_chart : PieChart, PieData;

        auto pie1 = new PieChart;
        root.addCreate(pie1);

        PieData[] data = [
            {"Item1 10", 10},
            {"Item2 20", 20},
            {"Item3 30", 30},
            {"Item4 40", 40}
        ];

        pie1.data(data);
    }

    private void createWindows(Container root)
    {
        import api.dm.gui.controls.buttons.button : Button;
        import api.dm.gui.controls.buttons.parallelogram_button : ParallelogramButton;
        import api.dm.gui.controls.switches.checks.check : Check;
        import IconName = api.dm.gui.themes.icons.icon_name;
        import api.dm.gui.containers.frame : Frame;

        auto frame = new Frame("Windows");
        frame.isVGrow = true;
        root.addCreate(frame);

        import api.dm.gui.containers.vbox : VBox;
        import api.dm.gui.containers.hbox : HBox;

        auto winRoot1 = new VBox(5);
        frame.addCreate(winRoot1);
        winRoot1.layout.isDecreaseRootWidth = true;

        auto winMin = new ParallelogramButton("Min", IconName.arrow_down_outline, (ref e) {
            logger.trace("Window is minimized before request: ", window.isMinimized);
            window.minimize;
            logger.trace("Window is minimized after request: ", window.isMinimized);
        });
        winRoot1.addCreate(winMin);

        auto winMax = new ParallelogramButton("Max", IconName.arrow_up_outline, (ref e) {
            logger.trace("Window is maximized before request: ", window.isMaximized);
            window.maximize;
            logger.trace("Window is maximized after request: ", window.isMaximized);
        });
        winRoot1.addCreate(winMax);
        winMax.layout.isFillFromStartToEnd = false;

        auto winRoot2 = new HBox(5);
        frame.addCreate(winRoot2);

        import api.dm.kit.sprites.layouts.vlayout : VLayout;
        import api.dm.kit.graphics.styles.default_style : DefaultStyle;

        auto winRestore = new Button("Restore", IconName.push_outline, (ref e) {
            window.restore;
        });
        winRestore.styleId = DefaultStyle.success;
        winRestore.layout = new VLayout(5);
        winRestore.layout.isAutoResizeAndAlignOne = true;
        winRestore.layout.isAlignX = true;

        winRoot2.addCreate(winRestore);

        auto winFull = new Button("FullScreen", IconName.expand_outline, (ref e) {
            auto oldValue = window.isFullScreen;
            logger.trace("Window fullscreen before request: ", oldValue);
            window.isFullScreen = !oldValue;
            logger.trace("Window fullscreen after request: ", window.isFullScreen);
        });

        winFull.styleId = DefaultStyle.danger;
        winFull.layout = new VLayout(5);
        winFull.layout.isAutoResizeAndAlignOne = true;
        winFull.layout.isAlignX = true;
        winFull.layout.isFillFromStartToEnd = false;
        winRoot2.addCreate(winFull);

        auto winRoot3 = new VBox(5);
        frame.addCreate(winRoot3);
        winRoot3.layout.isDecreaseRootWidth = true;

        auto winDec = new ParallelogramButton(null, IconName.image_outline, (ref e) {
            auto oldValue = window.isDecorated;
            logger.trace("Window decorated before request: ", oldValue);
            window.isDecorated = !oldValue;
            logger.trace("Window fullscreen after request: ", window.isDecorated);
        });
        winDec.styleId = DefaultStyle.warning;
        winDec.isInverted = true;
        winRoot3.addCreate(winDec);

        auto winResize = new ParallelogramButton(null, IconName.resize_outline, (ref e) {
            auto oldValue = window.isResizable;
            logger.trace("Window resizable before request: ", oldValue);
            window.isResizable = !oldValue;
            logger.trace("Window resizable after request: ", window.isResizable);
        });
        winResize.styleId = DefaultStyle.warning;
        winResize.isInverted = true;
        winRoot3.addCreate(winResize);
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

        // auto rb1 = new RadialProgressBar;
        // rb1.isPercentMode = true;
        // root.addCreate(rb1);
        // rb1.progress = 0.6;

        // import api.dm.gui.controls.gauges.hlinear_gauge : HLinearGauge;

        // auto ling1 = new HLinearGauge;
        // //ling1.isBorder = true;
        // root.addCreate(ling1);

        import api.dm.gui.controls.gauges.radial_gauge : RadialGauge;

        enum gaugeDiameter = 200;
        auto leftGauge = new RadialGauge(gaugeDiameter, 90, 270);
        root.addCreate(leftGauge);

        auto topGauge = new RadialGauge(gaugeDiameter, 180, 0);
        root.addCreate(topGauge);

        auto rightGauge = new RadialGauge(gaugeDiameter, 270, 90);
        root.addCreate(rightGauge);

        auto bottomGauge = new RadialGauge(gaugeDiameter, 0, 180);
        root.addCreate(bottomGauge);

        import api.dm.kit.sprites.tweens.pause_tween : PauseTween;

        auto gaugeAnim1 = new PauseTween(850);
        gaugeAnim1.isInfinite = true;
        auto gaugeAnim2 = new PauseTween(750);
        gaugeAnim2.isInfinite = true;
        auto gaugeAnim3 = new PauseTween(820);
        gaugeAnim3.isInfinite = true;
        auto gaugeAnim4 = new PauseTween(910);
        gaugeAnim4.isInfinite = true;

        import api.math.random : Random;

        auto rnd = new Random;

        import api.dm.kit.sprites.tweens.curves.uni_interpolator : UniInterpolator;

        leftGauge.handTween.interpolator.interpolateMethod = &UniInterpolator.backOut;
        topGauge.handTween.interpolator.interpolateMethod = &UniInterpolator.elasticOut;
        //quartOut, smootherStepOut, elasticOut
        rightGauge.handTween.interpolator.interpolateMethod = &UniInterpolator.bounceInOut;
        bottomGauge.handTween.interpolator.interpolateMethod = &UniInterpolator
            .smootherStepOut;

        gaugeAnim1.onEnd ~= () => leftGauge.value = rnd.between(0.0, 1.0);
        gaugeAnim2.onEnd ~= () => topGauge.value = rnd.between(0.0, 1.0);
        gaugeAnim3.onEnd ~= () => rightGauge.value = rnd.between(0.0, 1.0);
        gaugeAnim4.onEnd ~= () => bottomGauge.value = rnd.between(0.0, 1.0);

        root.addCreate([gaugeAnim1, gaugeAnim2, gaugeAnim3, gaugeAnim4]);

        // gaugeAnim1.run;
        // gaugeAnim2.run;
        // gaugeAnim3.run;
        // gaugeAnim4.run;
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
