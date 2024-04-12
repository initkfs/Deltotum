module dm.gui.controls.datetimes.calendar;

import dm.gui.controls.control : Control;
import dm.gui.containers.hbox : HBox;
import dm.gui.containers.vbox : VBox;
import dm.gui.controls.texts.text : Text;
import dm.gui.controls.buttons.button : Button;

import std.datetime;
import std.conv : to;

class DayContainer : Control
{
    Text dayLabel;
    Date dayDate;
    dstring placeholder;

    this(dstring placeholder = "  ")
    {
        import dm.kit.sprites.layouts.center_layout : CenterLayout;

        this.layout = new CenterLayout;
        this.layout.isAutoResize = true;

        this.placeholder = placeholder;
    }

    override void create()
    {
        super.create;
        this.dayLabel = new Text(placeholder);
        addCreate(dayLabel);
    }

    void reset()
    {
        dayLabel.text = placeholder;
        dayDate = Date.init;
    }
}

class WeekContainer : Control
{
    DayContainer[] days;

    this()
    {
        import dm.kit.sprites.layouts.hlayout : HLayout;

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

    Date currentDate;

    dstring[] weekDayNames;
    size_t weekCount = 5 + 1;

    override void initialize()
    {
        super.initialize;
        import dm.kit.sprites.layouts.vlayout : VLayout;

        this.layout = new VLayout;
        this.layout.isAutoResize = true;
        isBorder = true;
    }

    override void create()
    {
        super.create;

        Date date = getCurrentDate;

        Month month = date.month;
        short year = date.year;

        HBox dateChangeContainer = new HBox;
        dateChangeContainer.layout.isAlignY = true;
        addCreate(dateChangeContainer);
        dateChangeContainer.enableInsets;

        const prevNextButtonSize = 20;

        Button prevMonth = new Button("◀", prevNextButtonSize, prevNextButtonSize);
        prevMonth.onAction = (ref e) {
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
        Button nextMonth = new Button("▶", prevNextButtonSize, prevNextButtonSize);
        nextMonth.onAction = (ref e) {
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
        prevYear.onAction = (ref e) { decYear; load; };
        yearLabel = new Text(year.to!dstring);
        Button nextYear = new Button("▶", prevNextButtonSize, prevNextButtonSize);
        nextYear.onAction = (ref e) { incYear; load; };

        dateChangeContainer.addCreate([
            prevMonth, monthLabel, nextMonth, prevYear, yearLabel, nextYear
        ]);

        auto weekDayNameContainer = new WeekContainer;
        weekContainers ~= weekDayNameContainer;
        addCreate(weekDayNameContainer);

        weekDayNames = getWeekDayNames;
        foreach (weekName; weekDayNames)
        {
            auto weekDay = new DayContainer;
            weekDayNameContainer.addCreate(weekDay);
            weekDay.dayLabel.text = weekName;
        }

        foreach (wi; 0 .. weekCount)
        {
            WeekContainer weekContainer = new WeekContainer;
            weekContainers ~= weekContainer;
            addCreate(weekContainer);
            foreach (di; 0 .. weekDayNames.length)
            {
                auto dayContaner = new DayContainer;
                weekContainer.days ~= dayContaner;
                weekContainer.addCreate(dayContaner);
            }
        }

        // Button today = new Button("Today", prevNextButtonSize, prevNextButtonSize);
        // addCreate(today);

        foreach (week; weekContainers)
        {
            week.enableInsets;
        }

        load(getCurrentDate);
    }

    void load()
    {
        load(currentDate);
    }

    void load(Date date)
    {
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
                day.dayDate = date;
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
        import KitI18nKeys = dm.kit.kit_i18n_keys;

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
        import KitI18nKeys = dm.kit.kit_i18n_keys;

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
        foreach (week; weekContainers)
        {
            week.reset;
        }
    }

}
