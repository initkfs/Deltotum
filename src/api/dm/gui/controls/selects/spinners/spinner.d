module api.dm.gui.controls.selects.spinners.spinner;

import api.dm.gui.controls.selects.base_selector : BaseSelector;
import api.dm.gui.controls.expanders.expander : Expander, ExpanderPosition;
import api.dm.gui.controls.switches.buttons.button : Button;
import api.dm.gui.controls.switches.buttons.navigate_button : NavigateButton, NavigateDirection;
import api.dm.gui.controls.texts.textfield : TextField;

import std.conv : to;

/**
 * Authors: initkfs
 */
class Spinner(T) : BaseSelector!T
{
    TextField incLabel;
    bool isCreateIncLabel;
    TextField delegate(TextField) onNewIncLabel;
    void delegate(TextField) onCreatedIncLabel;

    Button incButton;
    bool isCreateIncButton;
    Button delegate(Button) onNewIncButton;
    void delegate(Button) onCreatedIncButton;

    TextField valueLabel;
    bool isCreateValueLabel = true;
    TextField delegate(TextField) onNewValueLabel;
    void delegate(TextField) onCreatedValueLabel;

    TextField decLabel;
    bool isCreateDecLabel;
    TextField delegate(TextField) onNewDecLabel;
    void delegate(TextField) onCreatedDecLabel;

    Button decButton;
    bool isCreateDecButton;
    Button delegate(Button) onNewDecButton;
    void delegate(Button) onCreatedDecButton;

    double textWidth = 0;

    protected {
        T initInc;
        T initDec;
        T initValue;
    }

    this(T initValue = T.init, T initInc = T.init, T initDec = T.init)
    {
        import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

        this.layout = new HLayout;
        layout.isAlignY = true;
        layout.isAutoResize = true;
        layout.isParentSizeReduce = true;

        this.initValue = initValue;
        this.initDec = initDec;
        this.initInc = initInc;
    }

    final void isCreateIncDec(bool value)
    {
        isCreateIncLabel = value;
        isCreateDecLabel = value;
        isCreateIncButton = value;
        isCreateDecButton = value;
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadSpinnerTheme;
    }

    void loadSpinnerTheme()
    {
        if (textWidth == 0)
        {
            textWidth = theme.controlDefaultWidth / 3;
        }
    }

    override void create()
    {
        super.create;

        if (!decButton && isCreateDecButton)
        {
            auto b = newDecButton;
            decButton = !onNewDecButton ? b : onNewDecButton(b);

            decButton.onPointerPress ~= (ref e) {
                const newValue = value - decValue;
                import std.conv : to;

                valueLabel.text = newValue.to!dstring;
            };

            addCreate(decButton);
            if (onCreatedDecButton)
            {
                onCreatedDecButton(decButton);
            }
        }

        import api.dm.gui.controls.containers.vbox : VBox;

        auto valueContainer = new VBox;
        valueContainer.layout.isParentSizeReduce = true;
        addCreate(valueContainer);

        if (!incLabel && isCreateIncLabel)
        {
            auto incTextExpander = new Expander;
            incTextExpander.expandPosition = ExpanderPosition.top;
            valueContainer.addCreate(incTextExpander);

            auto newLabel = newIncLabel;
            incLabel = !onNewIncLabel ? newLabel : onNewIncLabel(newLabel);
            incTextExpander.contentContainer.addCreate(incLabel);
            if (onCreatedIncLabel)
            {
                onCreatedIncLabel(incLabel);
            }
        }

        if (!valueLabel && isCreateValueLabel)
        {
            auto newLabel = newValueLabel;
            valueLabel = !onNewValueLabel ? newLabel : onNewValueLabel(newLabel);

            valueContainer.addCreate(valueLabel);
            if (onCreatedValueLabel)
            {
                onCreatedValueLabel(valueLabel);
            }
        }

        if (!decLabel && isCreateDecLabel)
        {
            auto decTextExpander = new Expander;
            decTextExpander.expandPosition = ExpanderPosition.bottom;
            valueContainer.addCreate(decTextExpander);

            auto newLabel = newDecLabel;
            decLabel = !onNewDecLabel ? newLabel : onNewDecLabel(newLabel);
            decTextExpander.contentContainer.addCreate(decLabel);
            if (onCreatedDecLabel)
            {
                onCreatedDecLabel(decLabel);
            }

        }

        if (!incButton && isCreateIncButton)
        {
            auto b = newIncButton;
            incButton = !onNewIncButton ? b : onNewIncButton(b);

            incButton.onPointerPress ~= (ref e) {
                import std.conv : to;

                const newValue = value + incValue;
                valueLabel.text = newValue.to!dstring;
            };

            addCreate(incButton);
            if (onCreatedIncButton)
            {
                onCreatedIncButton(incButton);
            }
        }
    }

    protected TextField setText(TextField text)
    {
        text.width = textWidth;
        text.isReduceWidthHeight = false;
        return text;
    }

    TextField newIncLabel()
    {
        return setText(new TextField(initInc.to!dstring));
    }

    TextField newValueLabel()
    {
        return setText(new TextField(initValue.to!dstring));
    }

    TextField newDecLabel()
    {
        return setText(new TextField(initDec.to!dstring));
    }

    Button newIncButton()
    {
        return new NavigateButton(NavigateDirection.toRight);
    }

    Button newDecButton()
    {
        return new NavigateButton(NavigateDirection.toLeft);
    }

    T incValue()
    {
        assert(incLabel);
        return incLabel.text.to!T;
    }

    T decValue()
    {
        assert(decLabel);
        return decLabel.text.to!T;
    }

    void value(T newValue)
    {
        valueLabel.text = newValue.to!dstring;
    }

    T value()
    {
        if (valueLabel.text.length == 0)
        {
            return T.init;
        }

        return valueLabel.text.to!T;
    }
}
