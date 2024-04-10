module dm.gui.supports.editors.sections.indicators;

// dfmt off
version(DmAddon):
// dfmt on

import dm.gui.controls.control : Control;
import dm.gui.containers.container : Container;
import dm.gui.containers.hbox : HBox;
import dm.gui.containers.vbox : VBox;
import dm.kit.graphics.colors.rgba: RGBA;

/**
 * Authors: initkfs
 */
class Indicators : Control
{
    this()
    {
        id = "deltotum_gui_editor_section_indicators";

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

    override void create()
    {
        super.create;

        auto rootContainer = new VBox;
        rootContainer.width = 500;
        rootContainer.height = 400;
        rootContainer.layout.isAlignY = true;
        addCreate(rootContainer);

        import dm.gui.containers.hbox : HBox;

        auto indicatorContainer = new HBox;
        indicatorContainer.layout.isAlignY = true;
        rootContainer.addCreate(indicatorContainer);
        indicatorContainer.enableInsets;

        createIndicators(indicatorContainer);
    }

    private void createIndicators(Container root)
    {
        import dm.addon.gui.controls.indicators.seven_segment : SevenSegment;

        auto ssContainer = new HBox;
        root.addCreate(ssContainer);

        auto ss1 = new SevenSegment;
        ssContainer.addCreate(ss1);
        ss1.show0to9(8);
        ss1.showSegmentLeftBottomDot;

        auto ss2 = new SevenSegment;
        ssContainer.addCreate(ss2);
        ss2.show0to9(9);

        import dm.addon.gui.controls.indicators.dot_matrix_display : DotMatrixDisplay;

        auto dm1 = new DotMatrixDisplay!(7, 5);
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
        dm1.draw(matrix);

        import dm.addon.gui.controls.indicators.gauges.gauge : Gauge;

        auto g1 = new Gauge;
        root.addCreate(g1);

        import dm.addon.gui.controls.indicators.leds.led : Led;
        import dm.math.interps.uni_interpolator : UniInterpolator;

        auto ledContainer = new VBox;
        root.addCreate(ledContainer);
        ledContainer.enableInsets;

        auto ledContainer1 = new HBox;
        ledContainer1.layout.isAlignY = true;
        ledContainer.addCreate(ledContainer1);
        ledContainer1.enableInsets;

        auto led1 = new Led(RGBA.red);
        ledContainer1.addCreate(led1);

        auto led2 = new Led(RGBA.yellow);
        ledContainer1.addCreate(led2);

        auto led3 = new Led(RGBA.green);
        ledContainer1.addCreate(led3);

        auto ledContainer2 = new HBox;
        ledContainer2.layout.isAlignY = true;
        ledContainer.addCreate(ledContainer2);
        ledContainer2.enableInsets;

        import dm.addon.gui.controls.indicators.leds.led_icon : LedIcon;
        import IconNames = dm.kit.graphics.themes.icons.icon_name;

        auto ledIcon1 = new LedIcon(IconNames.flash_outline, RGBA.red);
        ledContainer2.addCreate(ledIcon1);

        auto ledIcon2 = new LedIcon(IconNames.battery_charging_outline, RGBA.yellow);
        ledContainer2.addCreate(ledIcon2);

        auto ledIcon3 = new LedIcon(IconNames.thermometer_outline, RGBA.green);
        ledContainer2.addCreate(ledIcon3);
    }
}
