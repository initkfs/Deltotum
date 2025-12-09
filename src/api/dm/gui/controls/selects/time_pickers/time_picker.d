module api.dm.gui.controls.selects.time_pickers.time_picker;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.selects.time_pickers.dialogs.time_picker_dialog : TimePickerDialog;
import api.dm.gui.controls.selects.base_dropdown_selector : BaseDropDownSelector;
import api.dm.gui.controls.selects.time_pickers.dialogs.choosers.base_time_chooser : BaseTimeChooser;

import api.dm.gui.controls.texts.text : Text;
import api.dm.kit.assets.fonts.font_size : FontSize;
import api.dm.gui.controls.switches.buttons.button : Button;
import api.dm.gui.controls.switches.buttons.navigate_button : NavigateButton;

import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.geom2.vec2 : Vec2d;

import std.conv : to;
import std.format : format;
import std.datetime : TimeOfDay;
import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class TimePicker : BaseDropDownSelector!(TimePickerDialog, TimeOfDay)
{
    Container timeContainer;
    bool isCreateTimeContainer = true;
    Container delegate(Container) onNewTimeContainer;
    void delegate(Container) onConfiguredTimeContainer;
    void delegate(Container) onCreatedTimeContainer;

    Text hoursLabel;
    bool isCreateHoursLabel = true;
    Text delegate(Text) onNewHoursLabel;
    void delegate(Text) onConfiguredHoursLabel;
    void delegate(Text) onCreatedHoursLabel;

    Text minutesLabel;
    bool isCreateMinutesLabel = true;
    Text delegate(Text) onNewMinutesLabel;
    void delegate(Text) onConfiguredMinutesLabel;
    void delegate(Text) onCreatedMinutesLabel;

    Text secsLabel;
    bool isCreateSecsLabel = true;
    Text delegate(Text) onNewSecsLabel;
    void delegate(Text) onConfiguredSecsLabel;
    void delegate(Text) onCreatedSecsLabel;

    Button hourUp;
    bool isCreateHourUpButton = true;
    Button delegate(Button) onNewHourUpButton;
    void delegate(Button) onConfiguredHourUpButton;
    void delegate(Button) onCreatedHourUpButton;

    Button hourDown;
    bool isCreateHourDownButton = true;
    Button delegate(Button) onNewHourDownButton;
    void delegate(Button) onConfiguredHourDownButton;
    void delegate(Button) onCreatedHourDownButton;

    FontSize timeFontSize = timeFontSize.medium;

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
        isDropDownDialog = true;
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

            if (onConfiguredTimeContainer)
            {
                onConfiguredTimeContainer(timeContainer);
            }

            addCreate(timeContainer);

            timeContainer.enablePadding;

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

                assert(dialog.hourChooser);
                dialog.hourChooser.showForLayout;
                dialog.hourChooser.value(hoursLabel.text.to!int);

                assert(dialog.minChooser);
                dialog.minChooser.hideForLayout;

                assert(dialog.secChooser);
                dialog.secChooser.hideForLayout;
            };

            if (onConfiguredHoursLabel)
            {
                onConfiguredHoursLabel(hoursLabel);
            }
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

                assert(dialog.minChooser);
                dialog.minChooser.showForLayout;
                dialog.minChooser.value(minutesLabel.text.to!int);

                assert(dialog.hourChooser);
                dialog.hourChooser.hideForLayout;
                assert(dialog.secChooser);
                dialog.secChooser.hideForLayout;
            };

            if (onConfiguredMinutesLabel)
            {
                onConfiguredMinutesLabel(minutesLabel);
            }
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

                assert(dialog.secChooser);
                dialog.secChooser.showForLayout;
                dialog.secChooser.value(secsLabel.text.to!int);

                assert(dialog.hourChooser);
                dialog.hourChooser.hideForLayout;
                assert(dialog.minChooser);
                dialog.minChooser.hideForLayout;
            };

            if (onConfiguredSecsLabel)
            {
                onConfiguredSecsLabel(secsLabel);
            }
        }

        if (timeContainer)
        {
            import api.dm.gui.controls.containers.vbox : VBox;

            float spacing = 0;

            auto hoursContainer = new VBox(spacing);
            timeContainer.addCreate(hoursContainer);

            enum hourMaxValue = 23;
            enum hourMinValue = 0;
            setUpDownButtons(hoursContainer, hoursLabel, onCreatedHoursLabel, () {
                dialog.showOnlyHours;
                incValueWrap(hoursLabel, hourMinValue, hourMaxValue, dialog.hourChooser);
            }, () {
                dialog.showOnlyHours;
                decValueWrap(hoursLabel, hourMinValue, hourMaxValue, dialog.hourChooser);
            });

            timeContainer.addCreate(newText(":"));

            auto minContainer = new VBox(spacing);
            timeContainer.addCreate(minContainer);

            enum minSecMinValue = 0;
            enum minSecMaxValue = 59;

            setUpDownButtons(minContainer, minutesLabel, onCreatedMinutesLabel, () {
                dialog.showOnlyMins;
                incValueWrap(minutesLabel, minSecMinValue, minSecMaxValue, dialog.minChooser);
            }, () {
                dialog.showOnlyMins;
                decValueWrap(minutesLabel, minSecMinValue, minSecMaxValue, dialog.minChooser);
            });

            timeContainer.addCreate(newText(":"));

            auto secContainer = new VBox(spacing);
            timeContainer.addCreate(secContainer);

            setUpDownButtons(secContainer, secsLabel, onCreatedSecsLabel, () {
                dialog.showOnlySecs;
                incValueWrap(secsLabel, minSecMinValue, minSecMaxValue, dialog.secChooser);
            }, () {
                dialog.showOnlySecs;
                decValueWrap(secsLabel, minSecMinValue, minSecMaxValue, dialog.secChooser);
            });
        }

        createDialog((dialog) {
            dialog.onHourValue = (value) { setHourValue(value); };

            dialog.onMinValue = (value) { setMinValue(value); };

            dialog.onSecValue = (value) { setSecValue(value); };

            onShowPopup = (){
                reloadDialogTime;
            };

            window.showingTasks ~= (dt) {
                dialog.showOnlyHours;
                selectTextLabel(hoursLabel);
            };
        });

        reset;
    }

    void setHourValue(int value)
    {
        hoursLabel.text = formatTimeValue(value);
    }

    void setMinValue(int value)
    {
        minutesLabel.text = formatTimeValue(value);
    }

    void setSecValue(int value)
    {
        secsLabel.text = formatTimeValue(value);
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

    override TimePickerDialog newDialog() => new TimePickerDialog;

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

    protected void reloadTime(){
        setTime(current);
    }

    protected void reloadDialogTime(){
        setDialogTime(current);
    }

    void setCurrentTime(bool isTriggerListeners = true)
    {
        assert(dialog);
        import std.datetime : Clock;

        time(cast(TimeOfDay) Clock.currTime, isTriggerListeners);
    }

    void setTime(TimeOfDay newTime)
    {
        setHourValue(newTime.hour);
        setMinValue(newTime.minute);
        setSecValue(newTime.second);

        setDialogTime(newTime);
    }

    void time(TimeOfDay newTime, bool isTriggerListeners = true)
    {
        if (!current(newTime, isTriggerListeners))
        {
            return;
        }

        setTime(newTime);
    }

    protected bool setDialogTime(TimeOfDay newTime)
    {
        if (!dialog)
        {
            return false;
        }
        dialog.time(newTime);
        return true;
    }
}
