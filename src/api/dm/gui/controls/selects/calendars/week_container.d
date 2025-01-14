module api.dm.gui.controls.selects.calendars.week_container;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.selects.calendars.day_container: DayContainer;

import std.datetime;

/**
 * Authors: initkfs
 */
class WeekContainer : Control
{
    bool isDateRangeContainer;

    DayContainer[] days;

    this()
    {
        import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

        this.layout = new HLayout;
        this.layout.isAutoResize = true;
    }

    void reset()
    {
        foreach (day; days)
        {
            day.reset;
        }
    }
}
