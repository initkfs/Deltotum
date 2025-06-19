module api.dm.gui.controls.texts.text_field;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.texts.text_view : TextView;
import api.dm.kit.inputs.keyboards.events.key_event : KeyEvent;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;

import std.conv : to;

/**
 * Authors: initkfs
 */
class TextField : Control
{
    protected
    {
        dstring tempText;
        bool _isReduceWidthHeight;
    }

    TextView textView;
    Sprite2d clearButton;

    void delegate(ref KeyEvent) onEnter;

    this(dstring text = "")
    {
        this.tempText = text;
        isBorder = true;

        import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

        layout = new HLayout;
        layout.isAutoResize = true;
        layout.isAlignY = true;
    }

    override void initialize()
    {
        super.initialize;
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadTextFieldTheme;
    }

    void loadTextFieldTheme()
    {
        if (_width == 0)
        {
            _width = theme.controlDefaultWidth / 2;
        }

        if (_height == 0)
        {
            _height = theme.controlDefaultHeight / 2;
        }
    }

    override void create()
    {
        super.create;

        textView = new TextView(tempText);
        textView.isEditable = true;
        textView.isReduceWidthHeight = _isReduceWidthHeight;
        textView.paddingLeft = 5;
        textView.isHGrow = true;
        textView.isAddLastLineBreak = false;
        textView.isAllowWrapLine = false;

        textView.onEnter = (ref e) {
            if (onEnter)
            {
                onEnter(e);
            }
            return false;
        };

        addCreate(textView);

        auto clearButton = new Text("X");
        clearButton.paddingRight = 5;
        clearButton.isCreateInteractiveListeners = true;
        clearButton.onPointerPress ~= (ref e) {
            if (!textView.clear(isShowCursor : true))
            {
                logger.error("Error clear text view");
            }
            textView.focus;
        };

        this.clearButton = clearButton;

        addCreate(clearButton);
    }

    dstring text()
    {
        assert(textView);
        return textView.text;
    }

    void text(dstring t, bool isTriggerListeners = true)
    {
        assert(textView);
        textView.text(t, isTriggerListeners);
    }

    void text(string t, bool isTriggerListeners = true)
    {
        import std.conv : to;

        text(t.to!dstring, isTriggerListeners);
    }

    auto textTo(T)() => text.to!T;
    string textString() => textTo!string;

    bool isReduceWidthHeight()
    {
        assert(textView);
        return textView.isReduceWidthHeight;
    }

    void isReduceWidthHeight(bool v)
    {
        if (!textView)
        {
            _isReduceWidthHeight = v;
            return;
        }

        textView.isReduceWidthHeight = v;
    }
}
