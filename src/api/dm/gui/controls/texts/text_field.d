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

    dstring defaultValue;

    bool isCreateClearButton;
    Sprite2d clearButton;
    Sprite2d delegate(Sprite2d) onNewClearButton;
    void delegate(Sprite2d) onConfiguredClearButton;
    void delegate(Sprite2d) onCreatedClearButton;

    void delegate(ref KeyEvent) onEnter;

    this(dstring text = "", dstring defaultValue = null)
    {
        this.defaultValue = defaultValue;

        this.tempText = text;
        isBorder = true;
        isReduceWidthHeight = false;

        import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

        layout = new HLayout;
        layout.isAutoResize = true;
        layout.isAlignY = true;
    }

    override void initialize()
    {
        super.initialize;

        enablePadding;
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
            _height = theme.controlDefaultHeight / 1.5;
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

        if (!clearButton && isCreateClearButton)
        {
            auto btn = newClearButton;
            clearButton = !onNewClearButton ? btn : onNewClearButton(btn);

            import api.dm.gui.controls.control : Control;

            //TODO check HLayout\VLayout
            clearButton.marginLeft = theme.controlGraphicsGap * 1.5;

            if (auto control = cast(Control) clearButton)
            {
                control.isCreateInteractions = true;
            }

            clearButton.onPointerPress ~= (ref e) {
                
                if(textView.text == defaultValue){
                    return;
                }
                
                if (!textView.clear(defaultValue, isShowCursor:
                        true))
                {
                    logger.error("Error clear text view");
                }
                textView.hideCursor;
                textView.focus;
            };

            if (onConfiguredClearButton)
            {
                onConfiguredClearButton(clearButton);
            }

            addCreate(clearButton);

            if (onCreatedClearButton)
            {
                onCreatedClearButton(clearButton);
            }
        }
    }

    Sprite2d newClearButton()
    {
        import api.dm.gui.controls.switches.buttons.icon_button : IconButton;

        if (!platform.cap.isIconPack)
        {
            return new IconButton(dchar.init, 0, 0, "x");
        }

        import Icons = api.dm.gui.themes.icons.pack_bootstrap;

        return new IconButton(Icons.x_diamond_fill);
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
