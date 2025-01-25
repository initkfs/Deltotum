module api.dm.gui.controls.selects.time_pickers.dialogs.time_picker_dialog;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;

import api.dm.gui.controls.selects.time_pickers.dialogs.choosers.base_time_chooser : BaseTimeChooser;
import api.dm.gui.controls.selects.time_pickers.dialogs.choosers.hour_chooser : HourChooser;
import api.dm.gui.controls.selects.time_pickers.dialogs.choosers.minsec_chooser : MinSecChooser;

import Math = api.dm.math;
import std.datetime : TimeOfDay;

/**
 * Authors: initkfs
 */
class TimePickerDialog : Control
{
    HourChooser hourChooser;
    MinSecChooser minChooser;
    MinSecChooser secChooser;

    Sprite2d chooserContainer;

    void delegate(int) onHourValue;
    void delegate(int) onMinValue;
    void delegate(int) onSecValue;

    this()
    {
        import api.dm.kit.sprites2d.layouts.center_layout : CenterLayout;

        layout = new CenterLayout;
        layout.isAutoResize = true;
    }

    override void create()
    {
        super.create;

        import api.dm.gui.controls.containers.stack_box : StackBox;

        chooserContainer = new StackBox;
        addCreate(chooserContainer);

        hourChooser = new HourChooser;
        chooserContainer.addCreate(hourChooser);
        hourChooser.onNumValue = (hourValue) {
            if (onHourValue)
            {
                onHourValue(hourValue);
            }
        };

        minChooser = new MinSecChooser;
        chooserContainer.addCreate(minChooser);

        minChooser.onNumValue = (numValue) {
            if (onMinValue)
            {
                onMinValue(numValue);
            }
        };

        secChooser = new MinSecChooser;
        chooserContainer.addCreate(secChooser);

        secChooser.onNumValue = (numValue) {
            if (onSecValue)
            {
                onSecValue(numValue);
            }
        };
    }

    dstring formatTimeValue(int value)
    {
        import std.format : format;
        import std.conv : to;

        return format("%02d", value).to!dstring;
    }

    void showHours()
    {
        assert(hourChooser);
        hourChooser.showForLayout;
    }

    void showOnlyHours()
    {
        showHours;
        hideMins;
        hideSecs;
    }

    void showMins()
    {
        assert(minChooser);
        minChooser.showForLayout;
    }

    void showOnlyMins()
    {
        showMins;
        hideHours;
        hideSecs;
    }

    void showSecs()
    {
        assert(secChooser);
        secChooser.showForLayout;
    }

    void showOnlySecs()
    {
        showSecs;
        hideHours;
        hideMins;
    }

    void hideHours()
    {
        assert(hourChooser);
        hourChooser.hideForLayout;
    }

    void hideMins()
    {
        assert(minChooser);
        minChooser.hideForLayout;
    }

    void hideSecs()
    {
        assert(secChooser);
        secChooser.hideForLayout;
    }

    // TimeOfDay time()
    // {
    //     int h = hourChooser.value;
    //     int m = minChooser.value;
    //     int s = secChooser.value;
    //     return TimeOfDay(h, m, s);
    // }

    void time(TimeOfDay newTime)
    {
        hourChooser.value = newTime.hour;
        minChooser.value = newTime.minute;
        secChooser.value = newTime.second;
    }

}
