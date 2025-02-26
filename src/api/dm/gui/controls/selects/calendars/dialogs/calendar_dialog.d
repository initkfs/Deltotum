module api.dm.gui.controls.selects.calendars.dialogs.calendar_dialog;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.selects.calendars.day_container : DayContainer;
import api.dm.gui.controls.selects.calendars.week_container : WeekContainer;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.controls.switches.buttons.button : Button;
import KitI18nKeys = api.dm.gui.gui_i18n_keys;

import std.datetime : DayOfWeek, Date;
import std.conv : to;

/**
 * Authors: initkfs
 */
class CalendarDialog : Control
{
    WeekContainer[] weekContainers;
    DayContainer[] selected;
    DayContainer startSelected;

    bool isMultiSelected;
    void delegate(DayContainer) onSelectedDay;

    RGBA dayColor;
    RGBA holidayColor;

    dstring[] weekDayNames;
    size_t weekCount = 5 + 1;

    WeekContainer weekDayNameContainer;
    bool isCreateWeekDayNameContainer = true;
    WeekContainer delegate(WeekContainer) onNewWeekDayNameContainer;
    void delegate(WeekContainer) onConfiguredWeekDayNameContainer;
    void delegate(WeekContainer) onCreatedWeekDayNameContainer;

    WeekContainer delegate(WeekContainer) onNewWeekContainer;
    void delegate(WeekContainer) onConfiguredWeekContainer;
    void delegate(WeekContainer) onCreatedWeekContainer;

    DayContainer delegate(DayContainer) onNewDayContainer;
    void delegate(DayContainer) onConfiguredDayContainer;
    void delegate(DayContainer) onCreatedDayContainer;

    Container buttonContainer;
    bool isCreateButtonContainer;
    Container delegate(Container) onNewButtonContainer;
    void delegate(Container) onConfiguredButtonContainer;
    void delegate(Container) onCreatedButtonContainer;

    Button dayResetButton;
    bool isCreateDayResetButton = true;
    Button delegate(Button) onNewDayResetButton;
    void delegate(Button) onConfiguredDayResetButton;
    void delegate(Button) onCreatedDayResetButton;

    Button todayButton;
    bool isCreateTodayButton = true;
    Button delegate(Button) onNewTodayButton;
    void delegate(Button) onConfiguredTodayButton;
    void delegate(Button) onCreatedTodayButton;

    void delegate() onSelectToday;
    void delegate() onReset;

    this()
    {
        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        this.layout = new VLayout;
        this.layout.isAutoResize = true;
        this.layout.isAlignX = true;

        isBorder = true;
    }

    override void create()
    {
        super.create;

        if (!weekDayNameContainer && isCreateWeekDayNameContainer)
        {
            auto wc = newWeekDayNameContainer;
            weekDayNameContainer = !onNewWeekDayNameContainer ? wc : onNewWeekDayNameContainer(wc);

            weekDayNameContainer.isDateRangeContainer = false;
            weekContainers ~= weekDayNameContainer;

            if (onConfiguredWeekDayNameContainer)
            {
                onConfiguredWeekDayNameContainer(weekDayNameContainer);
            }

            addCreate(weekDayNameContainer);

            if (onCreatedWeekDayNameContainer)
            {
                onCreatedWeekDayNameContainer(weekDayNameContainer);
            }
        }

        weekDayNames = getWeekDayNames;
        foreach (weekName; weekDayNames)
        {
            auto weekDay = new DayContainer;
            weekDay.canMark = false;
            if (weekDayNameContainer)
            {
                weekDayNameContainer.addCreate(weekDay);
            }
            weekDay.dayLabel.text = weekName;
        }

        foreach (wi; 0 .. weekCount)
        {
            auto wc = newWeekContainer;
            auto weekContainer = !onNewWeekContainer ? wc : onNewWeekContainer(wc);
            weekContainer.isDateRangeContainer = true;
            weekContainers ~= weekContainer;

            if (onConfiguredWeekContainer)
            {
                onConfiguredWeekContainer(weekContainer);
            }

            addCreate(weekContainer);
            if (onCreatedWeekContainer)
            {
                onCreatedWeekContainer(weekContainer);
            }

            foreach (_di; 0 .. weekDayNames.length)
                (size_t di) {

                auto dc = newDayContainer;
                auto dayContainer = !onNewDayContainer ? dc : onNewDayContainer(dc);

                dayContainer.dayColor = dayColor;
                dayContainer.holidayColor = holidayColor;

                dayContainer.onMarkNewValue = (bool isMark) {
                    import std.algorithm.searching : canFind;

                    import api.dm.com.inputs.com_keyboard : ComKeyName;

                    const isShift = input.isPressedKey(ComKeyName.key_lshift) || input.isPressedKey(
                        ComKeyName.key_rshift);

                    //TODO not mark for current date

                    if (!isMark)
                    {
                        import std.algorithm.searching : countUntil;
                        import std.algorithm.mutation : remove;

                        auto pos = selected.countUntil(dayContainer);
                        if (pos == -1)
                        {
                            logger.trace("Not found day container in selected: ", dayContainer);
                            return;
                        }
                        selected = selected.remove(pos);
                        logger.trace("Remove day container from selected: ", dayContainer);
                        return;
                    }

                    if (isMultiSelected && isShift && startSelected && (startSelected !is dayContainer))
                    {
                        Date startDate;
                        Date endDate;
                        if (startSelected.dayDate < dayContainer.dayDate)
                        {
                            startDate = startSelected.dayDate;
                            endDate = dayContainer.dayDate;
                        }
                        else
                        {
                            startDate = dayContainer.dayDate;
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

                    if(!isMultiSelected){
                        foreach (dc; selected)
                        {
                            if(dayContainer is dc){
                                return;
                            }
                            dc.unmark(isTriggerListeners : false);
                        }
                        selected = null;
                    }

                    addSelected(dayContainer);
                };

                weekContainer.days ~= dayContainer;

                if (onConfiguredDayContainer)
                {
                    onConfiguredDayContainer(dayContainer);
                }

                weekContainer.addCreate(dayContainer);
                if (onCreatedDayContainer)
                {
                    onCreatedDayContainer(dayContainer);
                }
            }(_di);
        }

        foreach (week; weekContainers)
        {
            week.enablePadding;
        }

        if (!buttonContainer && isCreateButtonContainer)
        {
            auto bc = newButtonContainer;
            buttonContainer = !onNewButtonContainer ? bc : onNewButtonContainer(bc);

            if (onConfiguredButtonContainer)
            {
                onConfiguredButtonContainer(buttonContainer);
            }

            addCreate(buttonContainer);

            buttonContainer.enablePadding;

            if (onCreatedButtonContainer)
            {
                onCreatedButtonContainer(buttonContainer);
            }
        }

        if (!todayButton && isCreateTodayButton && isCreateButtonContainer)
        {
            auto tb = newTodayButton(i18n.getMessage(KitI18nKeys.dateToday, "Today"));
            todayButton = !onNewTodayButton ? tb : onNewTodayButton(tb);

            todayButton.onAction ~= (ref e) {
                if (onSelectToday)
                {
                    onSelectToday();
                }
            };

            if (onConfiguredTodayButton)
            {
                onConfiguredTodayButton(todayButton);
            }

            assert(buttonContainer);
            buttonContainer.addCreate(todayButton);
            if (onCreatedTodayButton)
            {
                onCreatedTodayButton(todayButton);
            }
        }

        if (!dayResetButton && isCreateDayResetButton && isCreateButtonContainer)
        {
            auto tb = newDayResetButton(i18n.getMessage(KitI18nKeys.uiReset, "Reset"));
            dayResetButton = !onNewDayResetButton ? tb : onNewDayResetButton(tb);

            dayResetButton.onAction ~= (ref e) {
                reset;
                if (onReset)
                {
                    onReset();
                }
            };

            if (onConfiguredDayResetButton)
            {
                onConfiguredDayResetButton(dayResetButton);
            }

            assert(buttonContainer);
            buttonContainer.addCreate(dayResetButton);
            if (onCreatedDayResetButton)
            {
                onCreatedDayResetButton(dayResetButton);
            }
        }
    }

    void load(Date date, Date currDate)
    {
        auto monthDates = getRangeDatesByWeek(date);
        //TODO check weekname index == 0
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
    }

    //TODO i18n
    protected bool isHoliday(Date date)
    {
        return date.dayOfWeek == DayOfWeek.sat || date.dayOfWeek == DayOfWeek.sun;
    }

    WeekContainer newWeekDayNameContainer() => new WeekContainer;
    WeekContainer newWeekContainer() => new WeekContainer;
    DayContainer newDayContainer() => new DayContainer;
    Button newTodayButton(dstring text) => new Button(text);
    Button newDayResetButton(dstring text) => new Button(text);

    Container newButtonContainer()
    {
        import api.dm.gui.controls.containers.hbox : HBox;

        auto container = new HBox;
        container.layout.isAlignY = true;
        return container;
    }

    protected bool addSelected(DayContainer container)
    {
        import std.algorithm.searching : canFind;

        assert(container);
        if (selected.canFind(container))
        {
            logger.trace("Day container already added: ", container);
            return false;
        }

        logger.trace("Add day container to selected: ", container);
        startSelected = container;
        selected ~= container;

        if(onSelectedDay){
            onSelectedDay(container);
        }

        return true;
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

    auto getRangeDatesByWeek(Date date, DayOfWeek startWeekDay = DayOfWeek.mon, DayOfWeek endWeekDay = DayOfWeek
            .sun)
    {
        auto datesMonth = datesInMonth(date);
        auto monthDates = datesByWeek(datesMonth, startWeekDay, endWeekDay);
        return monthDates;
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

    private dstring[] getWeekDayNames()
    {
        //TODO delegate onWeekDay
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
