module dm.gui.supports.editors.sections.controls;

import dm.gui.controls.control : Control;
import dm.gui.containers.container : Container;
import dm.kit.sprites.sprite : Sprite;
import dm.kit.graphics.colors.rgba : RGBA;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;
import dm.gui.controls.data.tree_table_view : TreeItem;
import dm.gui.controls.buttons.button : Button;
import dm.gui.containers.hbox : HBox;
import dm.gui.containers.vbox : VBox;
import dm.gui.containers.frame : Frame;
import dm.kit.sprites.layouts.vlayout : VLayout;

/**
 * Authors: initkfs
 */
class Controls : Control
{
    this()
    {
        id = "deltotum_gui_editor_section_controls";

        import dm.kit.sprites.layouts.vlayout : VLayout;

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

        auto container = new HBox;
        container.layout.isAlignY = false;
        rootContainer.addCreate(container);
        container.enableInsets;

        createTexts(container);

        createCharts(container);

        auto winContainer = new HBox(5);
        rootContainer.addCreate(winContainer);
        winContainer.enablePadding;
        createWindows(winContainer);

        // iconsContainer.isBackground = false;

        // import dm.kit.sprites.images.image : Image;

        // auto image1 = new Image();
        // build(image1);
        // image1.loadRaw(graphics.theme.iconData("rainy-outline"), 64, 64);
        // image1.setColor(graphics.theme.colorAccent);
    }

    void createButtons(Container root)
    {
        import dm.gui.controls.control : Control;

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
        import dm.gui.controls.choices.toggle_switch : ToggleSwitch;
        import dm.gui.controls.choices.checkbox : CheckBox;
        import dm.gui.controls.choices.choice_box : ChoiceBox;

        auto switch1 = new ToggleSwitch;
        root.addCreate(switch1);

        import dm.gui.controls.choices.checkbox : CheckBox;

        auto check1 = new CheckBox;
        root.addCreate(check1);
        check1.label.text = "Check";

        import dm.gui.controls.choices.choice_box : ChoiceBox;

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

        import dm.gui.controls.pickers.color_picker : ColorPicker;

        auto colorPicker = new ColorPicker;
        root.addCreate(colorPicker);
    }

    void createSeparators(Container root)
    {
        import dm.gui.controls.separators.vseparator : VSeparator;

        auto vsep = new VSeparator;
        vsep.height = 100;
        root.addCreate(vsep);

        import dm.gui.controls.sliders.hslider : HSlider;
        import dm.gui.controls.sliders.vslider : VSlider;

        auto vScrollbar = new VSlider;
        root.addCreate(vScrollbar);

        auto hScrollbar = new HSlider;
        root.addCreate(hScrollbar);

        import dm.gui.controls.separators.hseparator : HSeparator;

        auto hSep = new HSeparator;
        hSep.width = 100;
        root.addCreate(hSep);
    }

    void createDataControls(Container rootContainer)
    {

        import dm.gui.controls.data.tree_table_view : TreeTableView, TreeItem;

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

    void createCharts(Container root)
    {
        import dm.gui.controls.charts.linear_chart : LinearChart;

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
        import dm.gui.controls.buttons.button : Button;
        import dm.gui.controls.choices.checkbox : CheckBox;

        auto winMin = new Button("Min");
        root.addCreate(winMin);
        winMin.onAction = (ref e) {
            //TODO false,false 
            logger.trace("Window is minimized before request: ", window.isMinimized);
            window.minimize;
            logger.trace("Window is minimized after request: ", window.isMinimized);
        };

        auto winMax = new Button("Max");
        root.addCreate(winMax);
        winMax.onAction = (ref e) {
            logger.trace("Window is maximized before request: ", window.isMaximized);
            window.maximize;
            logger.trace("Window is maximized after request: ", window.isMaximized);
        };

        auto winRestore = new Button("Restore");
        root.addCreate(winRestore);
        winRestore.onAction = (ref e) { window.restore; };

        auto winFull = new Button("Fullscreen");
        root.addCreate(winFull);
        winFull.onAction = (ref e) {
            auto oldValue = window.isFullScreen;
            logger.trace("Window fullscreen before request: ", oldValue);
            window.isFullScreen = !oldValue;
            logger.trace("Window fullscreen after request: ", window.isFullScreen);
        };

        auto winDec = new Button("Decoration");
        root.addCreate(winDec);
        winDec.onAction = (ref e) {
            auto oldValue = window.isDecorated;
            logger.trace("Window decorated before request: ", oldValue);
            window.isDecorated = !oldValue;
            logger.trace("Window fullscreen after request: ", window.isDecorated);
        };

        auto winResize = new Button("Resizable");
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
        import dm.gui.controls.texts.text : Text;
        import dm.gui.controls.texts.text_view : TextView;
        import dm.gui.controls.texts.text_area : TextArea;

        auto t1 = new Text("Коммодор никак не мог отделаться от ощущения чудовищных перегрузок и невыносимой яркости освещения. Но он по-прежнему сидел в своем отсеке, хотя рука его еще лежала на клавише «Уничтожение». Экипаж, как и прежде, стоял строем, на лицах людей застыл ужас. Коммодор бросил взгляд на экран: чужого корабля не было видно, их окружал непроницаемый мрак. «Может, мне привиделся этот кошмар?» — подумал Коммодор. Он с трудом выпрямился за пультом.");
        t1.isEditable = true;
        t1.maxWidth = 350;
        t1.isBorder = true;
        root.addCreate(t1);
        t1.enableInsets;
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
