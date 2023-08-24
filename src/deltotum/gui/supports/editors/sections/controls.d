module deltotum.gui.supports.editors.sections.controls;

import deltotum.gui.controls.control : Control;
import deltotum.kit.sprites.sprite : Sprite;
import deltotum.kit.graphics.colors.rgba : RGBA;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

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

        import deltotum.gui.containers.hbox : HBox;
        import deltotum.gui.containers.vbox : VBox;
        import deltotum.gui.containers.frame : Frame;
        import deltotum.kit.sprites.layouts.vlayout : VLayout;

        auto rootContainer = new VBox(5);
        rootContainer.width = 500;
        rootContainer.height = 400;
        rootContainer.layout.isAlignY = true;
        addCreate(rootContainer);

        auto controlContainer1 = new HBox;
        rootContainer.addCreate(controlContainer1);

        import deltotum.gui.controls.choices.choice_box : ChoiceBox;

        dstring[] choiceItems = [
            "label1", "label2", "string1", "string2"
        ];

        auto choice1 = new ChoiceBox;
        controlContainer1.addCreate(choice1);
        choice1.fill(choiceItems);

        auto choice22 = new ChoiceBox;
        choice22.layout.isFillFromStartToEnd = false;
        controlContainer1.addCreate(choice22);
        choice22.fill(choiceItems);

        auto choice2 = new ChoiceBox;
        choice2.isCreateStepSelection = true;
        controlContainer1.addCreate(choice2);
        choice2.fill(choiceItems);

        auto choice3 = new ChoiceBox;
        auto vlayout = new VLayout(2);
        vlayout.isAutoResize = true;
        vlayout.isAlignX = true;
        choice3.layout = vlayout;
        choice3.isCreateStepSelection = true;
        controlContainer1.addCreate(choice3);
        choice3.fill(choiceItems);

        import deltotum.gui.controls.separators.vseparator: VSeparator;
        auto vsep = new VSeparator;
        controlContainer1.addCreate(vsep);

        import deltotum.gui.controls.sliders.hslider : HSlider;
        import deltotum.gui.controls.sliders.vslider : VSlider;

        auto vScrollbar = new VSlider;
        controlContainer1.addCreate(vScrollbar);

        auto hScrollbar = new HSlider;
        controlContainer1.addCreate(hScrollbar);

        import deltotum.gui.controls.separators.hseparator: HSeparator;
        auto hSep = new HSeparator;
        rootContainer.addCreate(hSep);

        auto controlContainer2 = new HBox;
        controlContainer2.layout.isAlignY = true;
        rootContainer.addCreate(controlContainer2);

        import deltotum.gui.controls.choices.toggle_switch : ToggleSwitch;

        auto switch1 = new ToggleSwitch;
        controlContainer2.addCreate(switch1);

        import deltotum.gui.controls.choices.checkbox : CheckBox;

        auto check1 = new CheckBox;
        controlContainer2.addCreate(check1);
        check1.label.text = "Check";

        import deltotum.gui.controls.pickers.color_picker : ColorPicker;

        auto colorPicker = new ColorPicker;
        controlContainer2.addCreate(colorPicker);

        auto chartContainer = new HBox;
        rootContainer.addCreate(chartContainer);

        import deltotum.gui.controls.charts.linear_chart: LinearChart;
        auto linearChart = new LinearChart;
        rootContainer.addCreate(linearChart);

        import std.range: iota;
        import std.array: array;
        import std.algorithm.iteration: map;
        import std.math.trigonometry: sin;

        double[] x = iota(1, 10, 0.01).array;
        double[] y = x.map!sin.array;
        
        linearChart.data(x, y);

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

}
