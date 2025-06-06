module api.dm.gui.controls.selects.calendars.calendar;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.gui.controls.switches.buttons.navigate_button : NavigateButton;
import api.dm.gui.controls.selects.calendars.dialogs.calendar_dialog : CalendarDialog;
import api.dm.gui.controls.selects.base_dropdown_selector : BaseDropDownSelector;

import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.texts.text_view: TextView;
import api.dm.gui.controls.switches.buttons.button : Button;

import KitI18nKeys = api.dm.gui.gui_i18n_keys;

import std.datetime;
import std.conv : to;
import std.algorithm.searching : canFind;

/**
 * Authors: initkfs
 */
class Calendar : BaseDropDownSelector!(CalendarDialog, Date)
{
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

    TextView dayLabel;
    TextView delegate(TextView) onNewDayLabel;
    void delegate(TextView) onConfiguredDayLabel;
    void delegate(TextView) onCreatedDayLabel;

    TextView monthLabel;
    TextView delegate(TextView) onNewMonthLabel;
    void delegate(TextView) onConfiguredMonthLabel;
    void delegate(TextView) onCreatedMonthLabel;

    TextView yearLabel;
    TextView delegate(TextView) onNewYearLabel;
    void delegate(TextView) onConfiguredYearLabel;
    void delegate(TextView) onCreatedYearLabel;

    RGBA dayColor;
    RGBA holidayColor;

    bool isHighlightCurrentDayEachMonth;

    this()
    {
        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        this.layout = new VLayout;
        this.layout.isAutoResize = true;
        this.layout.isAlignX = true;

        isBorder = true;
        isDropDownDialog = true;
    }

    override CalendarDialog newDialog() => new CalendarDialog;

    override void loadTheme()
    {
        super.loadTheme;
        loadCalendarTheme;
    }

    void loadCalendarTheme()
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

                dateChangeContainer.enablePadding;

                if (onCreatedDateChangeContainer)
                {
                    onCreatedDateChangeContainer(dateChangeContainer);
                }

                if (!dayLabel)
                {
                    auto dl = newDayLabel("00");
                    dayLabel = !onNewDayLabel ? dl : onNewDayLabel(dl);

                    dayLabel.isFocusable = false;
                    dayLabel.isReduceWidthHeight = false;

                    if (onConfiguredDayLabel)
                    {
                        onConfiguredDayLabel(dayLabel);
                    }

                    assert(dateChangeContainer);
                    dateChangeContainer.addCreate(dayLabel);
                }

                if (!prevMonthButton)
                {
                    prevMonthButton = createPrevNextButton(newPrevMonthButton, dateChangeContainer, (
                            btn) {
                        btn.onAction ~= (ref e) {

                            auto currMonth = current.month;

                            if (currMonth <= Month.min)
                            {
                                //TODO min year
                                decYear(isTriggerListeners : false);
                                auto newDate = current;
                                newDate.month = Month.max;
                                current(newDate);
                            }
                            else
                            {
                                auto newDate = current;
                                newDate.roll!"months"(-1);
                                current(newDate);
                            }
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
                            auto currMonth = current.month;
                            Month newMonth;
                            if (currMonth >= Month.max)
                            {
                                incYear(isTriggerListeners : false);
                                auto newDate = current;
                                newDate.month = Month.min;
                                current(newDate);
                            }
                            else
                            {
                                newMonth = ((cast(int) currMonth) + 1).to!Month;
                                auto newDate = current;
                                newDate.roll!"months"(1);
                                current(newDate);
                            }
                        };
                    });
                }

                if (!prevYearButton)
                {
                    prevYearButton = createPrevNextButton(newPrevYearButton, dateChangeContainer, (
                            btn) { btn.onAction ~= (ref e) { decYear; }; });
                }

                if (!yearLabel)
                {
                    auto ml = newYearLabel(year.to!dstring);
                    yearLabel = !onNewYearLabel ? ml : onNewYearLabel(ml);

                    yearLabel.isEditable = true;
                    yearLabel.isReduceWidthHeight = false;

                    yearLabel.onKeyPress ~= (ref e) {
                        import api.dm.com.inputs.com_keyboard : ComKeyName;

                        if (e.keyName == ComKeyName.key_return)
                        {
                            //TODO validate
                            try
                            {
                                auto newDate = current;
                                newDate.year = yearLabel.text.to!int;
                                current = newDate;
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
                            btn) { btn.onAction ~= (ref e) { incYear; }; });
                }
            }
        }

        onNewDialog = (dialog) {
            dialog.dayColor = dayColor;
            dialog.holidayColor = holidayColor;
            return dialog;
        };

        createDialog((dialog) {
            dialog.onSelectToday = () { setToday; };
            dialog.onReset = () { reload; };
            dialog.onSelectedDay = (dc) {
                auto date = current;
                date.day = dc.dayDate.day;
                current(date, true, false);
            };
        });

        setToday;
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

    Button newPrevMonthButton() => NavigateButton.newHPrevButton;
    Button newNextMonthButton() => NavigateButton.newHNextButton;
    Button newPrevYearButton() => NavigateButton.newHPrevButton;
    Button newNextYearButton() => NavigateButton.newHNextButton;
    TextView newMonthLabel(dstring text) => new TextView(text);
    TextView newYearLabel(dstring text) => new TextView(text);
    TextView newDayLabel(dstring text) => new TextView(text);

    void setToday()
    {
        current(getCurrentDate);
    }

    protected void setDialogDate(Date date, Date currDate)
    {
        assert(dialog);
        dialog.reset;
        dialog.load(date, currDate);
    }

    bool reload()
    {
        return current(current);
    }

    override inout(Date) current() inout => super.current;

    override bool current(Date date, bool isTriggerListeners = true, bool isSetDialog = true)
    {
        assert(monthLabel);
        assert(yearLabel);
        assert(dayLabel);

        if (!super.current(date, isTriggerListeners))
        {
            return false;
        }

        //TODO converters
        monthLabel.text = getMonthName(date.month);
        yearLabel.text = date.year.to!dstring;
        dayLabel.text = formatDay(date);

        if (isSetDialog)
        {
            auto currDate = getCurrentDate;
            if (isHighlightCurrentDayEachMonth && currDate != date)
            {
                currDate = date;
            }

            setDialogDate(date, currDate);
        }
        return true;
    }

    void incYear(bool isTriggerListeners = true)
    {
        const year = current.year;
        if (year == current.year.max)
        {
            return;
        }

        auto newDate = current;
        newDate.year = year + 1;
        current(newDate, isTriggerListeners);
    }

    void decYear(bool isTriggerListeners = true)
    {
        const year = current.year;
        if (year == 0 || year == current.year.min)
        {
            return;
        }

        auto newDate = current;
        newDate.year = year - 1;
        current(newDate, isTriggerListeners);
    }

    void updateDate()
    {
        current(getCurrentDate);
    }

    private Month onNewMonth(scope Month delegate(Month) onMonth)
    {
        auto month = current.month;
        return onMonth(month);
    }

    private int onNewYear(scope int delegate(int) onYear)
    {
        auto year = current.year;
        return onYear(year);
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

    protected dstring formatDay(Date date)
    {
        import std.conv : to;

        return date.day.to!dstring;
    }

    protected double getMaxMonthNameWidth(TextView label)
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
}
