module api.dm.gui.controls.selects.calendars.day_container;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.texts.text : Text;

import std.datetime;

/**
 * Authors: initkfs
 */
class DayContainer : Control
{
    dstring spacePlaceholder;

    Date dayDate;

    RGBA dayColor;
    RGBA holidayColor;

    Text dayLabel;
    bool isCreateDayLabel = true;
    Text delegate(Text) onNewDayLabel;
    void delegate(Text) onConfiguredDayLabel;
    void delegate(Text) onCreatedDayLabel;

    bool canMark = true;
    bool isEmpty = true;
    bool isHoliday;

    void delegate(bool) onMarkNewValue;

    protected
    {
        bool _mark;
    }

    this(dstring spacePlaceholder = "  ")
    {
        super();
        this.spacePlaceholder = spacePlaceholder;

        import api.dm.kit.sprites2d.layouts.center_layout : CenterLayout;

        this.layout = new CenterLayout;
        this.layout.isAutoResize = true;

        isBackground = true;

        onCreatedBackground = (newBackgound) {
            if (!_mark && hasBackground)
            {
                background.get.isVisible = false;
            }
        };
    }

    override Sprite2d newBackground()
    {
        auto style = createStyle;
        //TODO caps
        import api.dm.kit.sprites2d.textures.vectors.shapes.vconvex_polygon : VConvexPolygon;

        return new VConvexPolygon(width, height, style, 0);
    }

    override void create()
    {
        super.create;

        if (!dayLabel && isCreateDayLabel)
        {
            auto dl = newDayLabel;
            dayLabel = !onNewDayLabel ? dl : onNewDayLabel(dl);

            dayLabel.isReduceWidthHeight = false;
            dayLabel.isFocusable = false;
            dayLabel.color = dayColor;

            if (onConfiguredDayLabel)
            {
                onConfiguredDayLabel(dayLabel);
            }

            addCreate(dayLabel);

            if (onCreatedDayLabel)
            {
                onCreatedDayLabel(dayLabel);
            }
        }

        if (canMark)
        {
            onPointerPress ~= (ref e) {
                if (!canMark)
                {
                    return;
                }
                toggleMark;
            };
        }
    }

    Text newDayLabel()
    {
        return new Text(spacePlaceholder);
    }

    void setHoliday()
    {
        assert(dayLabel);
        dayLabel.color = holidayColor;
    }

    void unsetHoliday()
    {
        assert(dayLabel);
        isHoliday = false;
        if (dayLabel.color != dayColor)
        {
            dayLabel.color = dayColor;
        }
    }

    void toggleMark(bool isTriggerListeners = true)
    {
        if (_mark)
        {
            unmark(isTriggerListeners);
            return;
        }

        mark(isTriggerListeners);
    }

    void setMark()
    {
        _mark = true;
        if (hasBackground)
        {
            background.get.isVisible = true;
        }
    }

    void mark(bool isTriggerListeners = true)
    {
        setMark;
        if (onMarkNewValue && isTriggerListeners)
        {
            onMarkNewValue(_mark);
        }
    }

    void unmark(bool isTriggerListeners = true)
    {
        setUnmark;
        if (onMarkNewValue && isTriggerListeners)
        {
            onMarkNewValue(_mark);
        }
    }

    bool isMark() => _mark;

    void setUnmark()
    {
        _mark = false;
        if (hasBackground)
        {
            backgroundUnsafe.isVisible = false;
        }
    }

    void reset()
    {
        if (dayLabel)
        {
            dayLabel.text = spacePlaceholder;
        }

        isEmpty = true;
        if (isHoliday)
        {
            unsetHoliday;
        }
        setUnmark;
    }

    override string toString()
    {
        assert(dayLabel);
        import std.format : format;

        return format("%s, %s", dayLabel.text, dayDate);
    }
}
