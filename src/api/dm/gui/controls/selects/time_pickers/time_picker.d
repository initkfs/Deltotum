module api.dm.gui.controls.selects.time_pickers.time_picker;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.containers.container : Container;

import api.dm.gui.controls.selects.time_pickers.choosers.base_time_chooser : BaseTimeChooser;
import api.dm.gui.controls.selects.time_pickers.choosers.hour_chooser : HourChooser;
import api.dm.gui.controls.selects.time_pickers.choosers.minsec_chooser : MinSecChooser;

import api.dm.gui.controls.texts.text : Text;
import api.dm.kit.assets.fonts.font_size : FontSize;
import api.dm.gui.controls.switches.buttons.button : Button;
import api.dm.gui.controls.switches.buttons.navigate_button : NavigateButton;

import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.geom2.vec2 : Vec2d;

import std.conv : to;
import std.format : format;
import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class TimePicker : Control
{
    Container timeContainer;
    bool isCreateTimeContainer = true;
    Container delegate(Container) onNewTimeContainer;
    void delegate(Container) onCreatedTimeContainer;

    Text hoursLabel;
    bool isCreateHoursLabel = true;
    Text delegate(Text) onNewHoursLabel;
    void delegate(Text) onCreatedHoursLabel;

    Text minutesLabel;
    bool isCreateMinutesLabel = true;
    Text delegate(Text) onNewMinutesLabel;
    void delegate(Text) onCreatedMinutesLabel;

    Text secsLabel;
    bool isCreateSecsLabel = true;
    Text delegate(Text) onNewSecsLabel;
    void delegate(Text) onCreatedSecsLabel;

    Button hourUp;
    bool isCreateHourUpButton = true;
    Button delegate(Button) onNewHourUpButton;
    void delegate(Button) onCreatedHourUpButton;

    Button hourDown;
    bool isCreateHourDownButton = true;
    Button delegate(Button) onNewHourDownButton;
    void delegate(Button) onCreatedHourDownButton;

    FontSize timeFontSize = timeFontSize.large;

    HourChooser hourChooser;
    MinSecChooser minChooser;
    MinSecChooser secChooser;

    Sprite2d chooserContainer;

    protected
    {

    }

    this()
    {
        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        this.layout = new VLayout;
        this.layout.isAutoResize = true;
        this.layout.isAlignX = true;

        isBorder = true;
    }

    override void initialize()
    {
        super.initialize;
    }

    Container newTimeContainer()
    {
        import api.dm.gui.controls.containers.hbox : HBox;

        auto box = new HBox;
        box.isAlignY = true;
        return box;
    }

    Text newHoursLabel(dstring text = null) => newTimeLabel(text);
    Text newMinutesLabel(dstring text = null) => newTimeLabel(text);
    Text newSecsLabel(dstring text = null) => newTimeLabel(text);

    protected Text newTimeLabel(dstring text = null)
    {
        auto newText = text.length > 0 ? text : "00"d;
        auto label = new Text(newText);
        label.isBackground = true;
        return label;
    }

    override void create()
    {
        super.create;

        if (!timeContainer && isCreateTimeContainer)
        {
            auto container = newTimeContainer;
            timeContainer = !onNewTimeContainer ? container : onNewTimeContainer(container);

            addCreate(timeContainer);

            timeContainer.enableInsets;

            if (onCreatedTimeContainer)
            {
                onCreatedTimeContainer(timeContainer);
            }
        }

        if (!hoursLabel && isCreateHoursLabel)
        {
            auto label = newHoursLabel;
            hoursLabel = !onNewHoursLabel ? label : onNewHoursLabel(label);

            hoursLabel.fontSize = timeFontSize;
            hoursLabel.onPointerPress ~= (ref e) {

                selectTextLabel(hoursLabel);
                unselectTextLabel(minutesLabel);
                unselectTextLabel(secsLabel);

                assert(hourChooser);
                hourChooser.showForLayout;
                hourChooser.value(hoursLabel.text.to!int);

                assert(minChooser);
                minChooser.hideForLayout;

                assert(secChooser);
                secChooser.hideForLayout;
            };
        }

        if (!minutesLabel && isCreateMinutesLabel)
        {
            auto label = newMinutesLabel;
            minutesLabel = !onNewMinutesLabel ? label : onNewMinutesLabel(label);

            minutesLabel.fontSize = timeFontSize;
            minutesLabel.onPointerPress ~= (ref e) {

                selectTextLabel(minutesLabel);
                unselectTextLabel(hoursLabel);
                unselectTextLabel(secsLabel);

                assert(minChooser);
                minChooser.showForLayout;
                minChooser.value(minutesLabel.text.to!int);

                assert(hourChooser);
                hourChooser.hideForLayout;
                assert(secChooser);
                secChooser.hideForLayout;
            };
        }

        if (!secsLabel && isCreateSecsLabel)
        {
            auto label = newSecsLabel;
            secsLabel = !onNewSecsLabel ? label : onNewSecsLabel(label);

            secsLabel.fontSize = timeFontSize;
            secsLabel.onPointerPress ~= (ref e) {

                selectTextLabel(secsLabel);
                unselectTextLabel(hoursLabel);
                unselectTextLabel(minutesLabel);

                assert(secChooser);
                secChooser.showForLayout;
                secChooser.value(secsLabel.text.to!int);

                assert(hourChooser);
                hourChooser.hideForLayout;
                assert(minChooser);
                minChooser.hideForLayout;
            };
        }

        if (timeContainer)
        {
            import api.dm.gui.controls.containers.vbox : VBox;

            double spacing = 0;

            auto hoursContainer = new VBox(spacing);
            timeContainer.addCreate(hoursContainer);

            enum hourMaxValue = 23;
            enum hourMinValue = 0;
            setUpDownButtons(hoursContainer, hoursLabel, onCreatedHoursLabel, () {
                incValueWrap(hoursLabel, hourMinValue, hourMaxValue, hourChooser);
            }, () {
                decValueWrap(hoursLabel, hourMinValue, hourMaxValue, hourChooser);
            });

            timeContainer.addCreate(newText(":"));

            auto minContainer = new VBox(spacing);
            timeContainer.addCreate(minContainer);

            enum minSecMinValue = 0;
            enum minSecMaxValue = 59;

            setUpDownButtons(minContainer, minutesLabel, onCreatedMinutesLabel, () {
                incValueWrap(minutesLabel, minSecMinValue, minSecMaxValue, minChooser);
            }, () {
                decValueWrap(minutesLabel, minSecMinValue, minSecMaxValue, minChooser);
            });

            timeContainer.addCreate(newText(":"));

            auto secContainer = new VBox(spacing);
            timeContainer.addCreate(secContainer);

            setUpDownButtons(secContainer, secsLabel, onCreatedSecsLabel, () {
                incValueWrap(secsLabel, minSecMinValue, minSecMaxValue, secChooser);
            }, () {
                decValueWrap(secsLabel, minSecMinValue, minSecMaxValue, secChooser);
            });

        }

        import api.dm.gui.controls.containers.stack_box : StackBox;

        chooserContainer = new StackBox;
        addCreate(chooserContainer);

        hourChooser = new HourChooser;
        chooserContainer.addCreate(hourChooser);
        hourChooser.onNumValue = (hourValue) {
            hoursLabel.text = formatTimeValue(hourValue);
        };

        minChooser = new MinSecChooser;
        chooserContainer.addCreate(minChooser);

        minChooser.onNumValue = (numValue) {
            minutesLabel.text = formatTimeValue(numValue);
        };

        secChooser = new MinSecChooser;
        chooserContainer.addCreate(secChooser);

        secChooser.onNumValue = (numValue) {
            secsLabel.text = formatTimeValue(numValue);
        };

        window.showingTasks ~= (dt) {
            hourChooser.value(0);
            selectTextLabel(hoursLabel);
        };

        hourChooser.showForLayout;
        minChooser.hideForLayout;
        secChooser.hideForLayout;

        reset;

    }

    void selectTextLabel(Text label)
    {
        if (label && label.hasBackground)
        {
            label.backgroundUnsafe.isVisible = true;
        }
    }

    void unselectTextLabel(Text label)
    {
        if (label && label.hasBackground)
        {
            label.backgroundUnsafe.isVisible = false;
        }
    }

    protected void incValueWrap(Text label, int min, int max, BaseTimeChooser chooser)
    {
        auto value = label.text.to!int;
        if (value == max)
        {
            value = min;
        }
        else
        {
            value++;
        }
        label.text = formatTimeValue(value);
        if (chooser && chooser.isVisible)
        {
            chooser.value(value);
        }
    }

    protected void decValueWrap(Text label, int min, int max, BaseTimeChooser chooser)
    {
        auto value = label.text.to!int;
        if (value == min)
        {
            value = max;
        }
        else
        {
            value--;
        }
        label.text = formatTimeValue(value);
        if (chooser && chooser.isVisible)
        {
            chooser.value(value);
        }
    }

    Button newUpButton() => NavigateButton.newVNextButton;
    Button newDownButton() => NavigateButton.newVPrevButton;

    protected void setUpDownButtons(Container container, Text label, void delegate(Text) onCreatedLabel, void delegate() onUp, void delegate() onDown)
    {
        assert(onUp);
        assert(onDown);
        assert(container);
        assert(label);

        container.isAlignX = true;

        auto up = newUpButton;
        up.onAction ~= (ref e) { onUp(); };

        auto down = newDownButton;
        down.onAction ~= (ref e) { onDown(); };

        label.invalidateListeners ~= () {
            if (label.width <= 0 || label.height <= 0)
            {
                return;
            }
            up.width = label.width;
            down.width = label.width;
        };

        if (label.width == 0 && label.height == 0)
        {
            label.resize(1, 1);
        }

        container.addCreate(up);

        container.addCreate(label);
        unselectTextLabel(label);

        if (onCreatedLabel)
        {
            onCreatedLabel(label);
        }

        container.addCreate(down);
    }

    protected Text newText(dstring text = "")
    {
        auto t = new Text(text);
        t.fontSize = timeFontSize;
        return t;
    }

    int zeroTimeValue()
    {
        return 0;
    }

    dstring formatTimeValue(int value)
    {
        import std.format : format;
        import std.conv : to;

        return format("%02d", value).to!dstring;
    }

    dstring zeroTimeValueStr()
    {
        return formatTimeValue(zeroTimeValue);
    }

    void reset()
    {
        hoursLabel.text = zeroTimeValueStr;
        minutesLabel.text = zeroTimeValueStr;
        secsLabel.text = zeroTimeValueStr;
    }
}
