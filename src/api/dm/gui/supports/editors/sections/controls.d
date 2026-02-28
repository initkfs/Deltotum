module api.dm.gui.supports.editors.sections.controls;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.containers.container : Container;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.gui.controls.switches.buttons.button : Button;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.gui.controls.containers.vbox : VBox;
import api.dm.gui.controls.containers.frame : Frame;
import api.dm.kit.sprites2d.layouts.vlayout : VLayout;
import api.dm.gui.controls.selects.carousels.carousel;
import api.dm.gui.controls.selects.tables.clipped.trees.tree_item;

/**
 * Authors: initkfs
 */
class Controls : Control
{
    this()
    {
        id = "deltotum_gui_editor_section_controls";

        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

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
        //rootContainer.layout.isAlignY = true;
        addCreate(rootContainer);

        auto switchRoot = new HBox;
        switchRoot.width = width;
        switchRoot.layout.isAlignY = true;
        rootContainer.addCreate(switchRoot);

        createSwitches(switchRoot);

        import api.dm.gui.controls.separators.vseparator : VSeparator;
        import api.dm.gui.controls.separators.hseparator : HSeparator;

        switchRoot.addCreate(new VSeparator);

        createLabels(switchRoot);

        auto sep = new VSeparator;
        //TODO PosLayout in badges
        sep.marginLeft = 5;
        switchRoot.addCreate(sep);

        createSimpleTexts(switchRoot);
        createPickers(switchRoot);
        createProgress(switchRoot);

        rootContainer.addCreate(new HSeparator);

        auto selectionContainer = new HBox;
        selectionContainer.layout.isAlignY = true;
        rootContainer.addCreate(selectionContainer);

        createSelects(selectionContainer);

        createTexts(selectionContainer);

        auto metersContainer = new HBox;
        metersContainer.layout.isAlignY = true;
        rootContainer.addCreate(metersContainer);

        createMeters(metersContainer);

        auto dataContainer = new HBox(5);
        dataContainer.layout.isAlignY = true;
        rootContainer.addCreate(dataContainer);

        createCharts(dataContainer);

        createIndicators(dataContainer);
    }

    void createSwitches(Container root)
    {
        import api.dm.gui.controls.control : Control;
        import api.dm.gui.controls.containers.vbox : VBox;
        import api.dm.gui.controls.containers.hbox : HBox;

        auto btnRoot2 = new VBox;
        root.addCreate(btnRoot2);
        btnRoot2.layout.isDecreaseRootWidth = true;

        import api.dm.gui.controls.switches.buttons.parallelogram_button : ParallelogramButton;
        import api.dm.gui.controls.switches.buttons.button : Button;

        auto btn1 = new Button("Btn");
        btnRoot2.addCreate(btn1);

        auto btn2 = new ParallelogramButton("Btn");
        btn2.isBackground = true;
        btnRoot2.addCreate(btn2);

        auto btnRoot3 = new HBox;
        root.addCreate(btnRoot3);

        import api.dm.gui.controls.switches.buttons.round_button : RoundButton;

        auto roundRoot = new VBox;
        root.addCreate(roundRoot);

        auto circleBtn = new RoundButton("Btn");
        circleBtn.isLongPressButton = true;
        roundRoot.addCreate(circleBtn);

        import api.dm.gui.controls.switches.buttons.poly_button : PolyButton;

        import api.dm.kit.sprites2d.tweens.pause_tween : PauseTween;

        auto regBtn = new PolyButton("Btn");
        roundRoot.addCreate(regBtn);

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

        import api.dm.gui.controls.switches.switch_group : SwitchGroup;
        import api.dm.gui.controls.switches.checks.check : Check;
        import api.dm.gui.controls.selects.choices.choice : Choice;
        import Icons = api.dm.gui.themes.icons.pack_bootstrap;
        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;
        import api.dm.kit.sprites2d.layouts.hlayout : HLayout;
        import api.dm.gui.controls.switches.buttons.triangle_button : TriangleButton;

        auto toggleBtnContainer = new SwitchGroup;
        toggleBtnContainer.layout = new VLayout(0);
        toggleBtnContainer.layout.isAutoResize = true;
        toggleBtnContainer.layout.isAlignX = true;
        root.addCreate(toggleBtnContainer);

        import api.dm.kit.graphics.styles.default_style : DefaultStyle;

        auto tbtn1 = new TriangleButton(null, Icons.arrow_up_circle_fill, (ref e) {});
        tbtn1.styleId = DefaultStyle.warning;
        tbtn1.isFixedButton = true;
        tbtn1.isOn = true;
        toggleBtnContainer.addCreate(tbtn1);

        auto tbtn2 = new TriangleButton(null, Icons.arrow_down_circle_fill, (ref e) {});
        tbtn2.isFixedButton = true;
        tbtn2.angle = 180;
        tbtn2.styleId = DefaultStyle.danger;
        //tbtn2.isDrawBounds = true;
        toggleBtnContainer.addCreate(tbtn2);

        auto checkBoxContainer = new SwitchGroup;
        checkBoxContainer.layout = new VLayout;
        checkBoxContainer.layout.isAutoResize = true;
        root.addCreate(checkBoxContainer);

        auto check1 = new Check("Check1", Icons.database_fill_check);
        check1.isCreateIndeterminate = true;
        checkBoxContainer.addCreate(check1);
        check1.onPointerRelease ~= (ref e) {
            if (e.button == 3)
            {
                check1.isIndeterminate = true;
            }
        };

        auto check2 = new Check("Check2", Icons.person_fill_check);
        check2.isBorder = true;
        checkBoxContainer.addCreate(check2);
        check2.layout.isFillStartToEnd = false;
        check2.isOn = true;

        auto toggleContainer = new SwitchGroup;
        toggleContainer.layout = new VLayout;
        toggleContainer.layout.isAutoResize = true;
        root.addCreate(toggleContainer);

        import api.dm.gui.controls.switches.toggles.toggle : Toggle;
        import api.math.pos2.orientation : Orientation;

        auto switch1 = new Toggle(null, Icons.badge_hd_fill);
        switch1.isSwitchIcon = true;
        toggleContainer.addCreate(switch1);
        switch1.isOn = true;

        auto switch2 = new Toggle(null, Icons.bell_fill);
        switch2.isBorder = true;
        switch2.isSwitchIcon = true;
        toggleContainer.addCreate(switch2);

        auto switch1h = new Toggle(null, Icons.brightness_high_fill, Orientation.vertical);
        switch1h.isBorder = true;
        root.addCreate(switch1h);
        switch1h.isOn = true;
        switch1h.isSwitchContent = true;
    }

    void createDialogs(Container root)
    {
        import api.dm.gui.controls.containers.frame : Frame;
        import api.dm.gui.controls.containers.vbox : VBox;

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

            interact.popup.notify("Popup");
        });
        root3.addCreate(popBtn);

        auto popUrgBtn = new Button("Urgent", (ref e) {
            import std.conv : to;

            interact.popup.urgent("Popup urgent");
        });
        root3.addCreate(popUrgBtn);
    }

    void createSelects(Container root)
    {
        import api.dm.gui.controls.containers.hbox : HBox;

        auto tableRoot = new HBox;
        tableRoot.isAlignY = true;
        root.addCreate(tableRoot);

        import api.dm.gui.controls.selects.tables.circulars.circular_table;

        string[][] virtTableItems;

        import std.conv : to;

        foreach (i; 0 .. 10)
        {
            virtTableItems ~= [i.to!string, i.to!string];
        }

        auto virtTable = newCircularTable!string(2);
        tableRoot.addCreate(virtTable);

        virtTable.fill(virtTableItems);

        import api.dm.gui.controls.selects.tables.clipped.clipped_table : ClippedTable, newClippedTable;

        string[][] clipItems = [
            ["1", "1\n2"], ["2", "3"], ["3", "4\n5\n6"], ["4", "7"], [
                "5", "8\n9"
            ], ["6", "10"]
        ];

        auto clipTable = newClippedTable!string(2);
        tableRoot.addCreate(clipTable);
        clipTable.fill(clipItems);

        import api.dm.gui.controls.selects.tables.clipped.trees.tree_item : TreeItem;
        import api.dm.gui.controls.selects.tables.clipped.trees.tree_list : TreeList, newTreeList;

        auto treeTable = newTreeList!string;
        tableRoot.addCreate(treeTable);

        auto rootItem = new TreeItem!string("root1");

        auto rootItem2 = new TreeItem!string("root2");
        rootItem.childrenItems ~= rootItem2;
        rootItem2.childrenItems ~= [
            new TreeItem!string("1".to!string),
            new TreeItem!string("2".to!string)
        ];

        auto rootItem3 = new TreeItem!string("root3");
        rootItem2.childrenItems ~= rootItem3;

        foreach (i; 0 .. 11)
        {
            import std.conv : to;

            auto ni = new TreeItem!string(i.to!string);
            rootItem3.childrenItems ~= ni;
        }

        auto rootItem4 = new TreeItem!string("root4");
        rootItem.childrenItems ~= rootItem4;
        rootItem4.childrenItems ~= [
            new TreeItem!string("1".to!string),
            new TreeItem!string("2".to!string)
        ];

        treeTable.fill(rootItem);

        import api.dm.gui.controls.selects.choices.choice : Choice;

        dstring[] choiceItems;

        foreach (ci; 0 .. 11)
        {
            choiceItems ~= "label" ~ ci.to!dstring;
        }

        auto choiceRoot1 = new VBox;
        choiceRoot1.isAlignX = true;
        choiceRoot1.layout.isDecreaseRootHeight = true;
        root.addCreate(choiceRoot1);

        auto choiceHRoot1 = new HBox;
        choiceHRoot1.isAlignY = true;
        choiceHRoot1.layout.isDecreaseRootHeight = true;
        choiceRoot1.addCreate(choiceHRoot1);

        auto choice1 = new Choice!dstring;
        choiceHRoot1.addCreate(choice1);
        choice1.fill(choiceItems);

        import api.dm.gui.controls.meters.spinners.spinner : Spinner;

        auto spinner1 = new Spinner!int(5, 1, 1);
        spinner1.isCreateIncDec = true;
        choiceHRoot1.addCreate(spinner1);

        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
        import api.dm.kit.graphics.colors.rgba : RGBA;

        const imageSize = 35;
        auto style = GraphicStyle.transparentFill;

        auto carousel1 = new Carousel([
            theme.rectShape(imageSize, imageSize, 0, style.copyOfFillColor(RGBA.red)),
            theme.rectShape(imageSize, imageSize, 0, style.copyOfFillColor(RGBA.yellow)),
            theme.rectShape(imageSize, imageSize, 0, style.copyOfFillColor(RGBA.green)),
            theme.rectShape(imageSize, imageSize, 0, style.copyOfFillColor(RGBA.blue)),
        ]);

        choiceHRoot1.addCreate(carousel1);

        import api.dm.gui.controls.selects.paginations.pagination : Pagination;

        auto pagination = new Pagination;
        pagination.pageFactory = (size_t pageIndex) {};
        choiceRoot1.addCreate(pagination);
    }

    import api.dm.gui.controls.forms.regulates.regulate_text_field : RegulateTextField;

    RegulateTextField rField;
    RegulateTextField gField;
    RegulateTextField bField;

    void createPickers(Container root)
    {
        auto pickersRoot = new VBox;
        pickersRoot.isAlignX = true;
        root.addCreate(pickersRoot);

        import api.dm.gui.controls.selects.calendars.calendar : Calendar;

        auto cal1 = new Calendar;
        pickersRoot.addCreate(cal1);

        auto root2 = new HBox;
        root2.isAlignY = true;
        pickersRoot.addCreate(root2);

        import api.dm.gui.controls.selects.time_pickers.time_picker : TimePicker;

        import api.dm.gui.controls.selects.time_pickers.time_picker : TimePicker;

        auto timePick1 = new TimePicker;
        root2.addCreate(timePick1);
        timePick1.setCurrentTime;

        import api.dm.gui.controls.selects.color_pickers.color_picker : ColorPicker;

        auto colorPick2 = new ColorPicker;
        root2.addCreate(colorPick2);

        //import api.dm.kit.addon.media.ai.images.fusion_brain_api;
        // auto brainApi = new FusionBrainApi(logging, config, context);
        // brainApi.onImageBinaryData = (data) {

        //     import api.dm.kit.sprites2d.images.image : Image;

        //     auto fusionImage = new Image;
        //     build(fusionImage);
        //     fusionImage.loadRaw(data);

        //     root.addCreate(fusionImage);
        // };
        //brainApi.download("Нарисуй киберпанк котика на космическом корабле");
        //import std;
        //writeln(brainApi.requestPipeline);
    }

    void createMeters(Container root)
    {

        import api.dm.gui.controls.meters.scrolls.hscroll : HScroll;
        import api.dm.gui.controls.meters.scrolls.vscroll : VScroll;
        import api.dm.gui.controls.meters.scrolls.rscroll : RScroll;

        auto spacing = 10;

        auto container1 = new VBox(spacing);
        container1.layout.isAlignX = true;
        root.addCreate(container1);

        import api.dm.gui.controls.meters.scales.dynamics.hscale_dynamic : HScaleDynamic;

        auto hscaleDyn = new HScaleDynamic;
        hscaleDyn.isHGrow = true;
        container1.addCreate(hscaleDyn);

        import api.math.pos2.position : Pos;

        auto hs = new HScroll;
        hs.labelPos = Pos.bottomCenter;
        hs.isCreateLabel = true;
        container1.addCreate(hs);
        hs.width = hs.width * 1.5;

        auto hscaleDyn2 = new HScaleDynamic;
        hscaleDyn2.isInvertX = true;
        hscaleDyn2.isInvertY = true;
        hscaleDyn2.isHGrow = true;
        container1.addCreate(hscaleDyn2);

        import api.dm.gui.controls.meters.scales.dynamics.vscale_dynamic : VScaleDynamic;

        auto vscaleDyn = new VScaleDynamic;
        vscaleDyn.isVGrow = true;
        root.addCreate(vscaleDyn);

        auto vs = new VScroll;
        vs.labelPos = Pos.centerRight;
        vs.isCreateLabel = true;
        root.addCreate(vs);

        auto vscaleDyn2 = new VScaleDynamic;
        vscaleDyn2.isVGrow = true;
        vscaleDyn2.isInvertX = true;
        vscaleDyn2.isInvertY = true;
        root.addCreate(vscaleDyn2);

        auto gaugeContainer = new VBox;
        gaugeContainer.isAlignX = true;
        gaugeContainer.marginLeft = 10;
        root.addCreate(gaugeContainer);

        import api.dm.gui.controls.meters.gauges.hlinear_gauge : HLinearGauge;

        auto hLinGauge = new HLinearGauge(0, 1, 150);
        hLinGauge.isHGrow = true;
        gaugeContainer.addCreate(hLinGauge);

        gaugeContainer.spacing = -hLinGauge.height;

        import api.dm.gui.controls.meters.gauges.radial_gauge : RadialGauge;

        auto radGauge = new RadialGauge;
        radGauge.onCreatedLabel = (label) {
            label.updateRows;
            label.paddingBottom = label.height * 2;
        };
        gaugeContainer.addCreate(radGauge);

        radGauge.onPointerPress ~= (ref e) {
            import api.math.geom2.vec2 : Vec2f;

            auto pointerPos = radGauge.boundsRect.center.angleDeg360To(input.pointerPos);
            radGauge.valueAngle = pointerPos;
        };

        auto clockBox = new VBox(0);
        clockBox.layout.isAlignX = true;
        root.addCreate(clockBox);

        import api.dm.gui.controls.meters.clocks.analogs.analog_clock : AnalogClock;

        auto anClock = new AnalogClock;
        anClock.diameter = 150;
        anClock.isAutorun = true;
        clockBox.addCreate(anClock);

        import api.dm.gui.controls.meters.clocks.digitals.digital_clock : DigitalClock;

        auto digClock = new DigitalClock;
        digClock.isAutorun = true;
        clockBox.addCreate(digClock);
    }

    void createProgress(Container root)
    {
        auto progressContainer = new VBox;
        progressContainer.isAlignX = true;
        root.addCreate(progressContainer);

        import api.dm.gui.controls.meters.progress.base_progress_bar : BaseProgressBar;
        import api.dm.gui.controls.meters.progress.linear_progress_bar : LinearProgressBar;

        auto linProgressH = new LinearProgressBar;
        progressContainer.addCreate(linProgressH);
        linProgressH.value = 0.5;

        import api.dm.gui.controls.meters.progress.radial_progress_bar : RadialProgressBar;

        auto rProgress = new RadialProgressBar;
        progressContainer.addCreate(rProgress);
        rProgress.value = 0.5;

        import api.math.pos2.orientation : Orientation;

        auto linProgressV = new LinearProgressBar(0, 1.0, Orientation.vertical);
        root.addCreate(linProgressV);
        linProgressV.value = 0.5;

        import api.dm.kit.sprites2d.tweens.pause_tween : PauseTween;

        BaseProgressBar[3] progBars = [
            linProgressH, linProgressV, rProgress
        ];

        auto pTween = new PauseTween(200);
        progressContainer.addCreate(pTween);
        pTween.cycleCount = 11;
        pTween.onEnd ~= () {
            foreach (bar; progBars)
            {
                bar.value = bar.value + 0.1;
            }
        };
        pTween.onStop ~= () {
            foreach (bar; progBars)
            {
                bar.value = 0.5;
            }
        };

        auto runProgress = () {
            if (!pTween.isRunning)
            {
                foreach (bar; progBars)
                {
                    bar.value = 0;
                }
                pTween.run;
            }
        };

        rProgress.onPointerPress ~= (ref e) { runProgress(); };
        linProgressH.onPointerPress ~= (ref e) { runProgress(); };
        linProgressV.onPointerPress ~= (ref e) { runProgress(); };

        auto loaderContainer = new VBox;
        root.addCreate(loaderContainer);

        import api.dm.gui.controls.indicators.loaders.radial_loader : RadialLoader;

        auto loader1 = new RadialLoader;
        loaderContainer.addCreate(loader1);
        loader1.onPointerPress ~= (ref e) {
            if (loader1.isRunning)
            {
                loader1.stop;
            }
            else
            {
                loader1.run;
            }
        };

        import api.dm.gui.controls.meters.scrolls.rscroll : RScroll;

        auto rscroll1 = new RScroll;
        rscroll1.onNewScale = (scale) {
            scale.multiplyInitWidth = 1.2;
            return scale;
        };
        root.addCreate(rscroll1);
    }

    void createSeparators(Container root)
    {
        import api.dm.gui.controls.separators.vseparator : VSeparator;

        auto vsep = new VSeparator;
        vsep.height = 100;
        root.addCreate(vsep);

        import api.dm.gui.controls.meters.scrolls.hscroll : HScroll;
        import api.dm.gui.controls.meters.scrolls.vscroll : VScroll;
        import api.dm.gui.controls.meters.scrolls.rscroll : RScroll;

        auto vScrollbar = new VScroll;
        root.addCreate(vScrollbar);

        auto hScrollbar = new HScroll;
        root.addCreate(hScrollbar);

        auto rScroll = new RScroll;
        root.addCreate(rScroll);

        import api.dm.gui.controls.separators.hseparator : HSeparator;

        auto hSep = new HSeparator;
        hSep.width = 100;
        root.addCreate(hSep);
    }

    void createDataControls(Container rootContainer)
    {
        import api.dm.gui.controls.containers.scroll_box : ScrollBox;
        import api.dm.gui.controls.texts.text : Text;

        auto sb1 = new ScrollBox(100, 100);
        rootContainer.addCreate(sb1);
        auto sbt = new Text();
        sbt.maxWidth = 200;
        sb1.setContent(sbt);
        sbt.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";

        // import api.dm.gui.controls.selects.calendars.calendar : Calendar;

        // auto cal1 = new Calendar;
        // rootContainer.addCreate(cal1);

        // import api.dm.gui.controls.selects.time_pickers.time_picker : TimePicker;

        // auto time1 = new TimePicker;
        // rootContainer.addCreate(time1);

        import api.dm.gui.controls.selects.paginations.pagination : Pagination;
        import api.dm.gui.controls.texts.text : Text;
        import api.dm.gui.controls.containers.vbox : VBox;

        import api.dm.gui.controls.selects.carousels.carousel : Carousel;

        import api.dm.gui.controls.meters.clocks.analogs.analog_clock : AnalogClock;

        auto clock1 = new AnalogClock;
        rootContainer.addCreate(clock1);
    }

    void createCharts(Container root)
    {
        import api.dm.gui.controls.charts.lines.linear_chart : LinearChart;

        auto linearChart = new LinearChart;
        root.addCreate(linearChart);

        import std.range : iota;
        import std.array : array;
        import std.algorithm.iteration : map;
        import std.math.trigonometry : sin;

        //float[] x = iota(1, 10, 0.01).array;
        //float[] y = x.map!sin.array;

        float[] x = [0, 1, 2, 3, 7];
        float[] y = [0, 1, 2, 3, 7];

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

    private void createIndicators(Container root)
    {
        import api.dm.gui.controls.indicators.colorbars.colorbar : ColorBar;

        auto barsRoot1 = new VBox;
        barsRoot1.isAlignX = true;
        root.addCreate(barsRoot1);

        auto colorBar1 = new ColorBar;
        barsRoot1.addCreate(colorBar1);

        import api.dm.gui.controls.containers.center_box : CenterBox;

        auto barsStackRoot = new CenterBox;
        barsRoot1.addCreate(barsStackRoot);

        import api.dm.gui.controls.indicators.colorbars.radial_colorbar : RadialColorBar;

        auto radialBar1 = new RadialColorBar;
        barsStackRoot.addCreate(radialBar1);

        import api.dm.gui.controls.indicators.segmentbars.radial_segmentbar : RadialSegmentBar;

        auto radSBar1 = new RadialSegmentBar;
        barsStackRoot.addCreate(radSBar1);
        radSBar1.showSegments(3);

        import api.dm.gui.controls.indicators.sevsegments.seven_segment : SevenSegment;

        auto ssContainer = new HBox(10);
        root.addCreate(ssContainer);

        auto ss1 = new SevenSegment;
        ssContainer.addCreate(ss1);
        ss1.show0to9(8);
        ss1.showSegmentLeftBottomDot;

        auto ss2 = new SevenSegment;
        ssContainer.addCreate(ss2);
        ss2.show0to9(9);

        import api.dm.gui.controls.indicators.dotmatrix.dotmatrix_display : DotMatrixDisplay;

        auto dm1 = new DotMatrixDisplay!(7, 5);
        dm1.isBorder = true;
        root.addCreate(dm1);
        //dfmt off
        int[5][7] matrix = [
            [1, 0, 0, 0, 1],
            [1, 1, 0, 1, 1],
            [1, 0, 1, 0, 1],
            [1, 0, 0, 0, 1],
            [1, 0, 0, 0, 1],
            [1, 0, 0, 0, 1],
            [1, 0, 0, 0, 1]
        ];
        //dfmt on
        dm1.fromIntMatrix(matrix);

        import api.dm.gui.controls.indicators.leds.led : Led;
        import api.dm.kit.sprites2d.tweens.curves.uni_interpolator : UniInterpolator;

        auto ledContainer = new VBox;
        ledContainer.isAlignX = true;
        root.addCreate(ledContainer);
        ledContainer.enablePadding;

        auto ledContainer1 = new HBox;
        ledContainer1.layout.isAlignY = true;
        ledContainer.addCreate(ledContainer1);
        ledContainer1.enablePadding;

        auto led1 = new Led(RGBA.red);
        ledContainer1.addCreate(led1);

        auto led2 = new Led(RGBA.yellow);
        ledContainer1.addCreate(led2);

        auto led3 = new Led(RGBA.green);
        ledContainer1.addCreate(led3);

        auto ledContainer2 = new HBox;
        ledContainer2.layout.isAlignY = true;
        ledContainer.addCreate(ledContainer2);
        ledContainer2.enablePadding;

        import api.dm.gui.controls.indicators.leds.led_icon : LedIcon;
        import IconNames = api.dm.gui.themes.icons.pack_bootstrap;

        auto ledIcon1 = new LedIcon(IconNames.clock_fill, RGBA.red);
        ledContainer2.addCreate(ledIcon1);

        auto ledIcon2 = new LedIcon(IconNames.battery_full, RGBA.yellow);
        ledContainer2.addCreate(ledIcon2);

        auto ledIcon3 = new LedIcon(IconNames.thermometer_high, RGBA.green);
        ledContainer2.addCreate(ledIcon3);

        import api.dm.gui.controls.viewers.magnifiers.window_magnifier : WindowMagnifier;

        auto magn = new WindowMagnifier;
        root.addCreate(magn);
    }

    void createLabels(Container root)
    {
        auto labelRoot = new VBox;
        labelRoot.isAlignX = true;
        root.addCreate(labelRoot);

        import api.dm.gui.controls.labels.label : Label;
        import api.dm.gui.controls.labels.badges.badge : Badge;

        auto label1 = new Label("Badge");
        labelRoot.addCreate(label1);
        label1.addCreate(new Badge("123"));

        import api.dm.gui.controls.labels.hyperlinks.hyperlink : Hyperlink;

        auto h1 = new Hyperlink;
        h1.url = "https://google.com";
        labelRoot.addCreate(h1);
    }

    private void createSimpleTexts(Container root)
    {
        import api.dm.gui.controls.texts.text : Text;
        import api.dm.gui.controls.texts.text_field : TextField;

        auto fieldBox = new VBox;
        root.addCreate(fieldBox);

        auto text = new Text("Text with\nline breaks");
        text.isBorder = true;
        fieldBox.addCreate(text);
        text.enablePadding;

        auto textF1 = new TextField("0");
        textF1.defaultValue = "0";
        textF1.isCreateClearButton = true;
        fieldBox.addCreate(textF1);
    }

    private void createTexts(Container root)
    {
        import api.dm.gui.controls.texts.text_view : TextView;
        import api.dm.gui.controls.texts.text_field : TextField;
        import api.dm.gui.controls.texts.text_area : TextArea;

        import api.dm.gui.controls.containers.expanders.expander : Expander, ExpanderPosition;

        auto exp = new Expander;
        exp.expandPosition = ExpanderPosition.top;
        root.addCreate(exp);
        //exp.close;

        auto t1 = new TextArea("Коммодор никак не мог отделаться от ощущения чудовищных перегрузок и невыносимой яркости освещения. Но он по-прежнему сидел в своем отсеке, хотя рука его еще лежала на клавише «Уничтожение»...\nКоммодор никак не мог отделаться от ощущения чудовищных перегрузок и невыносимой яркости освещения. Но он по-прежнему сидел в своем отсеке, хотя рука его еще лежала на клавише «Уничтожение»...");
        t1.isEditable = true;
        t1.id = "TextArea";
        t1.width = 250;
        t1.height = 150;
        t1.isBorder = true;
        exp.contentContainer.addCreate(t1);
        t1.enablePadding;
    }

    private void createProgressBars(Container root)
    {
        import api.dm.gui.controls.meters.progress.radial_progress_bar : RadialProgressBar;

        // auto rb1 = new RadialProgressBar;
        // rb1.isPercentMode = true;
        // root.addCreate(rb1);
        // rb1.progress = 0.6;

        // import api.dm.gui.controls.meters.gauges.hlinear_gauge : HLinearGauge;

        // auto ling1 = new HLinearGauge;
        // //ling1.isBorder = true;
        // root.addCreate(ling1);

        import api.dm.gui.controls.meters.gauges.radial_gauge : RadialGauge;

        enum gaugeDiameter = 200;
        auto leftGauge = new RadialGauge(gaugeDiameter, 90, 270);
        root.addCreate(leftGauge);

        auto topGauge = new RadialGauge(gaugeDiameter, 180, 0);
        root.addCreate(topGauge);

        auto rightGauge = new RadialGauge(gaugeDiameter, 270, 90);
        root.addCreate(rightGauge);

        auto bottomGauge = new RadialGauge(gaugeDiameter, 0, 180);
        root.addCreate(bottomGauge);

        import api.dm.kit.sprites2d.tweens.pause_tween : PauseTween;

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

        import api.dm.kit.sprites2d.tweens.curves.uni_interpolator : UniInterpolator;

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

    private TreeItem!Sprite2d buildSpriteTree(Sprite2d root)
    {

        auto node = new TreeItem!Sprite2d(root);

        foreach (ch; root.children)
        {
            auto childNode = buildSpriteTree(ch);
            node.childrenItems ~= childNode;
        }

        return node;
    }

}
