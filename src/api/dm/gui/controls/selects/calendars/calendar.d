module api.dm.gui.controls.selects.calendars.calendar;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.selects.calendars.day_container : DayContainer;
import api.dm.gui.controls.selects.calendars.week_container : WeekContainer;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.gui.controls.switches.buttons.navigate_button : NavigateButton;

import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.switches.buttons.button : Button;

import KitI18nKeys = api.dm.gui.gui_i18n_keys;

import std.datetime;
import std.conv : to;
import std.algorithm.searching : canFind;

/**
 * Authors: initkfs
 */
class Calendar : Control
{
    Date currentDate;

    WeekContainer[] weekContainers;
    DayContainer[] selected;
    DayContainer startSelected;

    RGBA dayColor;
    RGBA holidayColor;

    dstring[] weekDayNames;
    size_t weekCount = 5 + 1;

    Container dateChangeContainer;
    bool isCreateDateChangeContainer = true;
    Container delegate(Container) onNewDateChangeContainer;
    void delegate(Container) onConfiguredDateChangeContainer;
    void delegate(Container) onCreatedDateChangeContainer;

    Button prevMonthButton;
    Button nextMonthButton;
    Button prevYearButton;
    Button nextYearButton;

    Button delegate(Button) onNewDatePrevNextButton;
    void delegate(Button) onCreatedDatePrevNextButton;
    void delegate(Button) onConfiguredDatePrevNextButton;

    Text monthLabel;
    Text delegate(Text) onNewMonthLabel;
    void delegate(Text) onConfiguredMonthLabel;
    void delegate(Text) onCreatedMonthLabel;

    Text yearLabel;
    Text delegate(Text) onNewYearLabel;
    void delegate(Text) onConfiguredYearLabel;
    void delegate(Text) onCreatedYearLabel;

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

    this()
    {
        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        this.layout = new VLayout;
        this.layout.isAutoResize = true;
        this.layout.isAlignX = true;

        isBorder = true;
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadDayContainerTheme;
    }

    void loadDayContainerTheme()
    {
        if (dayColor == RGBA.init)
        {
            dayColor = theme.colorText;
        }

        if (holidayColor == RGBA.init)
        {
            import MaterialPalette = api.dm.kit.graphics.colors.palettes.material_palette;

            holidayColor = RGBA.web(MaterialPalette.redA200);
        }
    }

    override void create()
    {
        super.create;

        Date date = getCurrentDate;

        Month month = date.month;
        short year = date.year;

        if (isCreateDateChangeContainer)
        {
            if (!dateChangeContainer)
            {
                auto dc = newDateChangeContainer;
                dateChangeContainer = !onNewDateChangeContainer ? dc : onNewDateChangeContainer(dc);

                if (onConfiguredDateChangeContainer)
                {
                    onConfiguredDateChangeContainer(dateChangeContainer);
                }

                addCreate(dateChangeContainer);

                dateChangeContainer.enableInsets;

                if (onCreatedDateChangeContainer)
                {
                    onCreatedDateChangeContainer(dateChangeContainer);
                }

                if (!prevMonthButton)
                {
                    prevMonthButton = createPrevNextButton(newPrevMonthButton, dateChangeContainer, (
                            btn) {
                        btn.onAction ~= (ref e) {
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
                    });
                }

                if (!monthLabel)
                {
                    auto ml = newMonthLabel(getMonthName(month));
                    monthLabel = !onNewMonthLabel ? ml : onNewMonthLabel(ml);

                    monthLabel.isFocusable = false;
                    monthLabel.isReduceWidthHeight = false;

                    if (onConfiguredMonthLabel)
                    {
                        onConfiguredMonthLabel(monthLabel);
                    }

                    assert(dateChangeContainer);
                    dateChangeContainer.addCreate(monthLabel);

                    double labelWidth = getMaxMonthNameWidth(monthLabel);
                    if (labelWidth > monthLabel.width)
                    {
                        monthLabel.width = labelWidth;
                    }

                    if (onCreatedMonthLabel)
                    {
                        onCreatedMonthLabel(monthLabel);
                    }
                }

                if (!nextMonthButton)
                {
                    nextMonthButton = createPrevNextButton(newNextMonthButton, dateChangeContainer, (
                            btn) {
                        btn.onAction ~= (ref e) {
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
                    });
                }

                if (!prevYearButton)
                {
                    prevYearButton = createPrevNextButton(newPrevYearButton, dateChangeContainer, (
                            btn) { btn.onAction ~= (ref e) { decYear; load; }; });
                }

                if (!yearLabel)
                {
                    auto ml = newYearLabel(year.to!dstring);
                    yearLabel = !onNewYearLabel ? ml : onNewYearLabel(ml);

                    yearLabel.isEditable = true;
                    yearLabel.isReduceWidthHeight = false;

                    yearLabel.onKeyPress ~= (ref e) {
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

                    if (onConfiguredYearLabel)
                    {
                        onConfiguredYearLabel(yearLabel);
                    }

                    assert(dateChangeContainer);
                    dateChangeContainer.addCreate(yearLabel);
                    if (onCreatedYearLabel)
                    {
                        onCreatedYearLabel(yearLabel);
                    }
                }

                if (!nextYearButton)
                {
                    nextYearButton = createPrevNextButton(newNextYearButton, dateChangeContainer, (
                            btn) { btn.onAction ~= (ref e) { incYear; load; }; });
                }
            }
        }

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

                    const isShift = input.isPressedKey(ComKeyName.LSHIFT) || input.isPressedKey(
                        ComKeyName.RSHIFT);

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

                    if (isShift && startSelected && (startSelected !is dayContainer))
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
            week.enableInsets;
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

            buttonContainer.enableInsets;

            if (onCreatedButtonContainer)
            {
                onCreatedButtonContainer(buttonContainer);
            }
        }

        if (!todayButton && isCreateTodayButton && isCreateButtonContainer)
        {
            auto tb = newTodayButton(i18n.getMessage(KitI18nKeys.dateToday, "Today"));
            todayButton = !onNewTodayButton ? tb : onNewTodayButton(tb);

            todayButton.onAction ~= (ref e) { loadToday; };

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

            dayResetButton.onAction ~= (ref e) { reset; load; };

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

        load(getCurrentDate);
    }

    protected Button createPrevNextButton(Button newButton, Sprite2d root, scope void delegate(
            Button) onPreCreate = null)
    {
        assert(newButton);
        assert(root);

        auto prevNextButton = !onNewDatePrevNextButton ? newButton : onNewDatePrevNextButton(
            newButton);

        if (onPreCreate)
        {
            onPreCreate(prevNextButton);
        }

        if (onConfiguredDatePrevNextButton)
        {
            onConfiguredDatePrevNextButton(prevNextButton);
        }

        root.addCreate(prevNextButton);
        if (onCreatedDatePrevNextButton)
        {
            onCreatedDatePrevNextButton(prevNextButton);
        }
        return prevNextButton;
    }

    Container newDateChangeContainer()
    {
        auto container = new HBox;
        container.layout.isAlignY = true;
        container.isBorder = true;
        return container;
    }

    Container newButtonContainer()
    {
        auto container = new HBox;
        container.layout.isAlignY = true;
        return container;
    }

    Button newPrevMonthButton() => NavigateButton.newHPrevButton;
    Button newNextMonthButton() => NavigateButton.newHNextButton;
    Button newPrevYearButton() => NavigateButton.newHPrevButton;
    Button newNextYearButton() => NavigateButton.newHNextButton;
    Text newMonthLabel(dstring text) => new Text(text);
    Text newYearLabel(dstring text) => new Text(text);
    WeekContainer newWeekDayNameContainer() => new WeekContainer;
    WeekContainer newWeekContainer() => new WeekContainer;
    DayContainer newDayContainer() => new DayContainer;
    Button newTodayButton(dstring text) => new Button(text);
    Button newDayResetButton(dstring text) => new Button(text);

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

    protected double getMaxMonthNameWidth(Text label)
    {
        import std.traits : EnumMembers;

        double maxW = 0;
        foreach (Month m; EnumMembers!Month)
        {
            auto nameLen = label.calcTextWidth(getMonthName(m));
            if (nameLen > maxW)
            {
                maxW = nameLen;
            }
        }
        return maxW;
    }

    private Date getCurrentDate()
    {
        Date date = cast(Date) Clock.currTime();
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
