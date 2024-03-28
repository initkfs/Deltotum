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
        monthLabel = new Text(month.to!dstring);
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
        monthLabel.text = currentDate.month.to!dstring;
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
        auto month = monthLabel.text.to!Month;
        return onMonth(month);
    }

    private int onNewYear(scope int delegate(int) onYear)
    {
        auto year = yearLabel.text.to!int;
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
        dstring[] weekNames = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"];
        return weekNames;
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
