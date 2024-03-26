module dm.gui.controls.spinners.spinner;

import dm.gui.controls.control : Control;
import dm.gui.controls.expanders.expander : Expander, ExpanderPosition;
import dm.gui.controls.buttons.button : Button;
import dm.gui.controls.texts.textfield : TextField;

import dm.gui.containers.hbox: HBox;
import dm.gui.containers.vbox: VBox;

import std.conv : to;

/**
 * Authors: initkfs
 */
class Spinner(T) : Control
{
    protected
    {
        TextField incText;
        TextField valueText;
        TextField decText;
    }

    this()
    {
        import dm.kit.sprites.layouts.hlayout: HLayout;

        this.layout = new HLayout(2);
        layout.isAlignY = true;
        layout.isAutoResize = true;
        layout.isAutoSizeReduction = true;
    }

    override void create()
    {
        super.create;

        auto minWidthField = 50;

        auto decButton = new Button("-", 15, 15);
        decButton.onPointerDown ~= (ref e){
            const newValue = value - decValue;
            valueText.text = newValue.to!dstring;
        };
        //decButton.isVGrow = true;
        addCreate(decButton);

        auto valueContainer = new VBox;
        valueContainer.layout.isAutoSizeReduction = true;
        addCreate(valueContainer);

        auto incTextExpander = new Expander;
        incTextExpander.expandPosition  = ExpanderPosition.top;
        valueContainer.addCreate(incTextExpander);

        incText = new TextField("0");
        incText.minWidth = minWidthField;
        incTextExpander.contentContainer.addCreate(incText);

        valueText = new TextField("0");
        valueText.minWidth = minWidthField;
        valueContainer.addCreate(valueText);

        auto decTextExpander = new Expander;
        decTextExpander.expandPosition  = ExpanderPosition.bottom;
        valueContainer.addCreate(decTextExpander);

        decText = new TextField("0");
        decText.minWidth = minWidthField;
        decTextExpander.contentContainer.addCreate(decText);

        auto incButton = new Button("+", 15, 15);
        incButton.onPointerDown ~= (ref e){
            const newValue = value + incValue;
            valueText.text = newValue.to!dstring;
        };
        //incButton.isVGrow = true;
        addCreate(incButton);
    }

    T incValue(){
        assert(incText);
        return incText.text.to!T;
    }

    T decValue(){
        assert(decText);
        return decText.text.to!T;
    }

    void value(T newValue)
    {
        valueText.text = newValue.to!dstring;
    }

    T value()
    {
        if (valueText.text.length == 0)
        {
            return T.init;
        }

        return valueText.text.to!T;
    }
}
