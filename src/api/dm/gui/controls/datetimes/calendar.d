module api.dm.gui.controls.datetimes.calendar;

import api.dm.gui.controls.control : Control;
import api.dm.gui.containers.hbox : HBox;
import api.dm.gui.containers.vbox : VBox;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.buttons.button : Button;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.graphics.colors.rgba : RGBA;
import KitI18nKeys = api.dm.gui.gui_i18n_keys;

import std.datetime;
import std.conv : to;
import std.algorithm.searching : canFind;

class DayContainer : Control
{
    dstring spacePlaceholder;

    Text dayLabel;
    Date dayDate;

    bool canMark = true;
    bool isEmpty = true;
    bool isHoliday;

    void delegate(bool) onMarkNewValue;

    RGBA holidayColor;

    protected
    {
        RGBA dayColor;
    }

    protected
    {
        bool _mark;
    }

    this(dstring spacePlaceholder = "  ")
    {
        super();
        this.spacePlaceholder = spacePlaceholder;

        import api.dm.kit.sprites.layouts.center_layout : CenterLayout;

        this.layout = new CenterLayout;
        this.layout.isAutoResize = true;

        isBackground = true;

        onBackgroundCreated = (newBackgound) {
            if (!_mark && hasBackground)
            {
                background.get.isVisible = false;
            }
        };
    }

    override Sprite newBackground(double w, double h)
    {
        auto style = createStyle;
        //TODO caps
        import api.dm.kit.sprites.textures.vectors.shapes.vconvex_polygon : VConvexPolygon;

        return new VConvexPolygon(w, h, style, 0);
    }

    override void create()
    {
        super.create;

        dayColor = theme.colorText;

        this.dayLabel = new Text(spacePlaceholder);
        dayLabel.isFocusable = false;
        addCreate(dayLabel);
        dayLabel.color = dayColor;

        if (canMark)
        {
            onPointerDown ~= (ref e) {
                if (!canMark)
                {
                    return;
                }
                toggleMark;
            };
        }
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

    void toggleMark()
    {
        if (_mark)
        {
            unmark;
            return;
        }

        mark;
    }

    void setMark()
    {
        _mark = true;
        if (hasBackground)
        {
            background.get.isVisible = true;
        }
    }

    void mark()
    {
        setMark;
        if (onMarkNewValue)
        {
            onMarkNewValue(_mark);
        }
    }

    //TODO isSelected in parent
    bool isMark()
    {
        return _mark;
    }

    void setUnmark()
    {
        _mark = false;
        if (hasBackground)
        {
            background.get.isVisible = false;
        }
    }

    void unmark()
    {
        setUnmark;
        if (onMarkNewValue)
        {
            onMarkNewValue(_mark);
        }
    }

    void reset()
    {
        dayLabel.text = spacePlaceholder;
        dayDate = Date.init;
        isEmpty = true;
        unsetHoliday;
        setUnmark;
    }

    override string toString()
    {
        assert(dayLabel);
        import std.format : format;

        return format("%s, %s", dayLabel.text, dayDate);
    }
}

class WeekContainer : Control
{
    bool isDateRangeContainer;

    DayContainer[] days;

    this()
    {
        import api.dm.kit.sprites.layouts.hlayout : HLayout;

        this.layout = new HLayout(5);
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

/**
 * Authors: initkfs
 */
class Calendar : Control
{
    WeekContainer[] weekContainers;

    Text monthLabel;
    Text yearLabel;

    Button resetButton;
    Button todayButton;

    Date currentDate;

    RGBA holidayColor;

    dstring[] weekDayNames;
    size_t weekCount = 5 + 1;

    DayContainer[] selected;
    DayContainer startSelected;

    override void initialize()
    {
        super.initialize;
        import api.dm.kit.sprites.layouts.vlayout : VLayout;

        this.layout = new VLayout;
        this.layout.isAutoResize = true;
        this.layout.isAlignX = true;
        isBorder = true;
    }

    override void create()
    {
        super.create;

        import MaterialPalette = api.dm.kit.graphics.colors.palettes.material_palette;

        holidayColor = RGBA.web(MaterialPalette.redA200);

        Date date = getCurrentDate;

        Month month = date.month;
        short year = date.year;

        HBox dateChangeContainer = new HBox;
        dateChangeContainer.layout.isAlignY = true;
        addCreate(dateChangeContainer);
        dateChangeContainer.enableInsets;

        const prevNextButtonSize = 20;

        Button prevMonth = new Button("◀", prevNextButtonSize, prevNextButtonSize);
        prevMonth.onAction ~= (ref e) {
            currentDate.month = onNewMonth((Month month) {
                if (month <= Month.min)
                {
                    decYear;
                    return Month.max;
                }
                return (month - 1).to!Month;
            });
            load;
        };

        monthLabel = new Text(getMonthName(month));
        monthLabel.isFocusable = false;

        Button nextMonth = new Button("▶", prevNextButtonSize, prevNextButtonSize);
        nextMonth.onAction ~= (ref e) {
            currentDate.month = onNewMonth((Month month) {
                auto newMonthNum = (cast(int) month) + 1;
                if (newMonthNum >= Month.max)
                {
                    incYear;
                    return Month.min;
                }
                return newMonthNum.to!Month;
            });
            load;
        };

        Button prevYear = new Button("◀", prevNextButtonSize, prevNextButtonSize);
        prevYear.onAction ~= (ref e) { decYear; load; };

        yearLabel = new Text(year.to!dstring);
        yearLabel.isEditable = true;

        yearLabel.onKeyDown ~= (ref e) {
            import api.dm.com.inputs.com_keyboard : ComKeyName;

            if (e.keyName == ComKeyName.RETURN)
            {
                //TODO validate
                try
                {
                    currentDate.year = yearLabel.text.to!int;
                }
                catch (Exception e)
                {
                    logger.trace("Error setting year from text field", e);
                }
            }

        };

        Button nextYear = new Button("▶", prevNextButtonSize, prevNextButtonSize);
        nextYear.onAction ~= (ref e) { incYear; load; };

        dateChangeContainer.addCreate([
            prevMonth, monthLabel, nextMonth, prevYear, yearLabel, nextYear
        ]);

        auto weekDayNameContainer = new WeekContainer;
        weekDayNameContainer.isDateRangeContainer = false;
        weekContainers ~= weekDayNameContainer;
        addCreate(weekDayNameContainer);

        weekDayNames = getWeekDayNames;
        foreach (weekName; weekDayNames)
        {
            auto weekDay = new DayContainer;
            weekDay.canMark = false;
            weekDayNameContainer.addCreate(weekDay);
            weekDay.dayLabel.text = weekName;
        }

        foreach (wi; 0 .. weekCount)
        {
            WeekContainer weekContainer = new WeekContainer;
            weekContainer.isDateRangeContainer = true;
            weekContainers ~= weekContainer;
            addCreate(weekContainer);
            foreach (_di; 0 .. weekDayNames.length)
                (size_t di) {
                auto dayContaner = new DayContainer;
                dayContaner.holidayColor = holidayColor;
                dayContaner.onMarkNewValue = (bool isMark) {
                    import std.algorithm.searching : canFind;

                    import api.dm.com.inputs.com_keyboard : ComKeyName;

                    const isShift = input.isPressedKey(ComKeyName.LSHIFT) || input.isPressedKey(
                        ComKeyName.RSHIFT);

                    //TODO not mark for current date

                    if (!isMark)
                    {
                        import std.algorithm.searching : countUntil;
                        import std.algorithm.mutation : remove;

                        auto pos = selected.countUntil(dayContaner);
                        if (pos == -1)
                        {
                            logger.trace("Not found day container in selected: ", dayContaner);
                            return;
                        }
                        selected = selected.remove(pos);
                        logger.trace("Remove day container from selected: ", dayContaner);
                        return;
                    }

                    if (isShift && startSelected && (startSelected !is dayContaner))
                    {
                        Date startDate;
                        Date endDate;
                        if (startSelected.dayDate < dayContaner.dayDate)
                        {
                            startDate = startSelected.dayDate;
                            endDate = dayContaner.dayDate;
                        }
                        else
                        {
                            startDate = dayContaner.dayDate;
                            endDate = startSelected.dayDate;
                        }

                        logger.tracef("Found dates for selected, start %s, end %s", startDate, endDate);

                        //TODO best selection
                        foreach (week; weekContainers)
                        {
                            if (week.isDateRangeContainer)
                            {
                                foreach (day; week.days)
                                {
                                    if (day.isEmpty)
                                    {
                                        continue;
                                    }
                                    const dayDate = day.dayDate;
                                    if (dayDate > startDate && dayDate < endDate)
                                    {
                                        day.setMark;
                                        addSelected(day);
                                    }
                                }
                            }
                        }

                    }

                    addSelected(dayContaner);
                };
                weekContainer.days ~= dayContaner;
                weekContainer.addCreate(dayContaner);
            }(_di);
        }

        // Button today = new Button("Today", prevNextButtonSize, prevNextButtonSize);
        // addCreate(today);

        foreach (week; weekContainers)
        {
            week.enableInsets;
        }

        import api.dm.gui.containers.hbox : HBox;
        import api.dm.gui.containers.container : Container;

        auto btnContainer = new HBox;
        addCreate(btnContainer);
        btnContainer.enableInsets;

        todayButton = new Button(i18n.getMessage(KitI18nKeys.dateToday, "Today"));
        todayButton.onAction ~= (ref e) { loadToday; };

        resetButton = new Button(i18n.getMessage(KitI18nKeys.uiReset, "Reset"));
        resetButton.onAction ~= (ref e) { reset; load; };

        btnContainer.addCreate([todayButton, resetButton]);

        load(getCurrentDate);
    }

    //TODO i18n
    protected bool isHoliday(Date date)
    {
        return date.dayOfWeek == DayOfWeek.sat || date.dayOfWeek == DayOfWeek.sun;
    }

    protected bool addSelected(DayContainer container)
    {
        assert(container);
        if (selected.canFind(container))
        {
            logger.trace("Day container already added: ", container);
            return false;
        }

        logger.trace("Add day container to selected: ", container);
        startSelected = container;
        selected ~= container;
        return true;
    }

    void loadToday()
    {
        load(getCurrentDate);
    }

    void load()
    {
        load(currentDate);
    }

    void load(Date date)
    {
        const currDate = getCurrentDate;
        reset;
        auto monthDates = getRangeDatesByWeek(date);
        size_t weekIndex = 1;
        foreach (monthWeek; monthDates)
        {
            if (weekIndex >= weekContainers.length)
            {
                throw new Exception(
                    "Out of bounds week container with index: " ~ weekIndex.to!string);
            }

            auto weekContainer = weekContainers[weekIndex];
            foreach (monthDate; monthWeek)
            {
                auto dayWeekIndex = dayOfWeekToWeekDayIndex(monthDate.dayOfWeek);
                assert(dayWeekIndex < weekContainer.days.length);
                auto day = weekContainer.days[dayWeekIndex];
                assert(day);
                assert(day.dayLabel.text);
                day.dayLabel.text = monthDate.day.to!dstring;
                day.dayDate = monthDate;
                day.isEmpty = false;

                if (isHoliday(monthDate))
                {
                    day.setHoliday;
                }

                if (currDate == monthDate)
                {
                    day.setMark;
                }
            }
            weekIndex++;
        }

        currentDate = date;
        monthLabel.text = getMonthName(currentDate.month);
        yearLabel.text = currentDate.year.to!dstring;
    }

    void incYear()
    {
        const year = currentDate.year;
        if (year == currentDate.year.max)
        {
            return;
        }

        currentDate.year = year + 1;
    }

    void decYear()
    {
        const year = currentDate.year;
        if (year == 0 || year == currentDate.year.min)
        {
            return;
        }

        currentDate.year = year - 1;
    }

    void updateDate()
    {
        currentDate = getCurrentDate;
    }

    private Month onNewMonth(scope Month delegate(Month) onMonth)
    {
        auto month = currentDate.month;
        return onMonth(month);
    }

    private int onNewYear(scope int delegate(int) onYear)
    {
        auto year = currentDate.year;
        return onYear(year);
    }

    auto getRangeDatesByWeek(Date date, DayOfWeek startWeekDay = DayOfWeek.mon, DayOfWeek endWeekDay = DayOfWeek
            .sun)
    {
        auto datesMonth = datesInMonth(date);
        auto monthDates = datesByWeek(datesMonth, startWeekDay, endWeekDay);
        return monthDates;
    }

    size_t dayOfWeekToWeekDayIndex(DayOfWeek day)
    {
        assert(weekDayNames.length > 0);

        int dayWeekIndex = day.to!int - 1;
        if (dayWeekIndex < 0)
        {
            dayWeekIndex = weekDayNames.length.to!int - 1;
        }
        return dayWeekIndex.to!size_t;
    }

    private dstring[] getWeekDayNames()
    {
        dstring[] weekNames = [
            i18n.getMessage(KitI18nKeys.dateWeekMo, "Mo"),
            i18n.getMessage(KitI18nKeys.dateWeekTu, "Tu"),
            i18n.getMessage(KitI18nKeys.dateWeekWe, "We"),
            i18n.getMessage(KitI18nKeys.dateWeekTh, "Th"),
            i18n.getMessage(KitI18nKeys.dateWeekFr, "Fr"),
            i18n.getMessage(KitI18nKeys.dateWeekSa, "Sa"),
            i18n.getMessage(KitI18nKeys.dateWeekSu, "Su")
        ];
        return weekNames;
    }

    private dstring getMonthName(Month month)
    {
        import KitI18nKeys = api.dm.gui.gui_i18n_keys;

        final switch (month) with (Month)
        {
            case jan:
                return i18n.getMessage(KitI18nKeys.dateMonthJan, "january");
                break;
            case feb:
                return i18n.getMessage(KitI18nKeys.dateMonthFeb, "february");
                break;
            case mar:
                return i18n.getMessage(KitI18nKeys.dateMonthMar, "march");
                break;
            case apr:
                return i18n.getMessage(KitI18nKeys.dateMonthApr, "april");
                break;
            case may:
                return i18n.getMessage(KitI18nKeys.dateMonthMay, "may");
                break;
            case jun:
                return i18n.getMessage(KitI18nKeys.dateMonthJun, "june");
                break;
            case jul:
                return i18n.getMessage(KitI18nKeys.dateMonthJul, "july");
                break;
            case aug:
                return i18n.getMessage(KitI18nKeys.dateMonthAug, "august");
                break;
            case sep:
                return i18n.getMessage(KitI18nKeys.dateMonthSep, "september");
                break;
            case oct:
                return i18n.getMessage(KitI18nKeys.dateMonthOct, "october");
                break;
            case nov:
                return i18n.getMessage(KitI18nKeys.dateMonthNov, "november");
                break;
            case dec:
                return i18n.getMessage(KitI18nKeys.dateMonthDec, "december");
                break;
        }
    }

    private Date getCurrentDate()
    {
        auto today = Clock.currTime();
        Date date = cast(Date) today;
        return date;
    }

    private auto datesInMonth(Date date) pure
    {
        import std;

        auto endDate = date.endOfMonth;
        return Date(date.year, date.month, 1)
            .recurrence!((a, n) => a[n - 1] + 1.days)
            .until!(a => a > endDate);
    }

    auto datesByWeek(Range)(Range dates, DayOfWeek startDay, DayOfWeek endDay)
    {
        import std;

        static struct DatesByWeek
        {
            Range r;
            DayOfWeek startDayWeek;
            DayOfWeek endDayWeek;

            bool empty() => r.empty;
            auto front() => until!((Date d) => d.dayOfWeek == endDayWeek)(r, OpenRight.no);

            void popFront()
            {
                assert(!r.empty());
                r.popFront();
                while (!r.empty && r.front.dayOfWeek != startDayWeek)
                {
                    r.popFront();
                }
            }
        }

        return DatesByWeek(dates, startDay, endDay);
    }

    void reset()
    {
        startSelected = null;
        selected = null;
        foreach (week; weekContainers)
        {
            week.reset;
        }
    }

}
