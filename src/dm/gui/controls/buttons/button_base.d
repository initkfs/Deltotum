module dm.gui.controls.buttons.button_base;

import dm.kit.sprites.sprite : Sprite;
import dm.gui.controls.labeled : Labeled;
import dm.kit.sprites.shapes.shape : Shape;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;
import dm.kit.sprites.shapes.rectangle : Rectangle;
import dm.gui.events.action_event : ActionEvent;
import dm.gui.controls.texts.text : Text;
import dm.kit.sprites.textures.texture : Texture;
import dm.kit.graphics.colors.rgba : RGBA;

import std.traits : isSomeString;

enum ButtonType
{
    normal,
    cancel,
    close,
    next,
    no,
    ok,
    previous,
    yes
}

/**
 * Authors: initkfs
 */
class ButtonBase : Labeled
{

    void delegate(ref ActionEvent) onAction;

    bool isCreateTextFactory = true;

    Text delegate() textFactory;

    bool isCancel;
    void delegate() onCancel;

    bool isDefault;
    void delegate() onDefault;

    protected
    {
        Text _text;

        dstring _buttonText;
        bool _selected;
        string iconName;
    }

    string idControlBackground = "btn_background";

    enum double defaultWidth = 80;
    enum double defaultHeight = 30;
    enum double defaultGraphicsGap = 5;

    //TODO mixins for children
    this(dstring text = "Button", string iconName)
    {
        this(text, defaultWidth, defaultHeight, defaultGraphicsGap, iconName);
    }

    this(
        dstring text = "Button",
        double width = defaultWidth,
        double height = defaultHeight,
        double graphicsGap = defaultGraphicsGap,
        string iconName = null
    )
    {
        super(iconName, graphicsGap);
        this.width = width;
        this.height = height;
        this._buttonText = text;
    }

    override void initialize()
    {
        super.initialize;

        if (isCanEnableInsets)
        {
            enableInsets;
        }

        if (!textFactory && isCreateTextFactory)
        {
            textFactory = createTextFactory;
        }
    }

    override Sprite delegate(double, double) createBackgroundFactory()
    {
        return (width, height) {
            assert(graphics.theme);

            auto style = styleFromActionType;
            auto newBackground = graphics.theme.background(width, height, &style);
            newBackground.isLayoutManaged = false;
            newBackground.id = idControlBackground;
            return newBackground;
        };
    }

    Text delegate() createTextFactory()
    {
        return () {
            auto text = new Text();
            build(text);
            //String can be forced to be empty
            //if (_buttonText.length > 0)
            text.text = _buttonText;
            return text;
        };
    }

    override void create()
    {
        super.create;

        if (iconName)
        {
            addCreateIcon(iconName);
        }

        if (textFactory)
        {
            _text = textFactory();
            if (_text)
            {
                addCreate(_text);
            }
            else
            {
                logger.error("Text factory did not return the object");
            }
        }

        createListeners;
    }

    void createListeners()
    {
        onPointerEntered ~= (ref e) {

            if (isDisabled || _selected)
            {
                return;
            }

            if (hover && !hover.isVisible)
            {
                hover.isVisible = true;
            }
        };

        onPointerExited ~= (ref e) {

            if (isDisabled || _selected)
            {
                return;
            }

            if (hover && hover.isVisible)
            {
                hover.isVisible = false;
            }
        };

        onPointerUp ~= (ref e) {

            if (isDisabled || _selected)
            {
                return;
            }

            if (pointerEffect && !pointerEffect.isVisible)
            {
                pointerEffect.isVisible = true;
                if (pointerEffectAnimation && !pointerEffectAnimation.isRunning)
                {
                    pointerEffectAnimation.run;
                }

            }

            if (onAction)
            {
                auto ea = ActionEvent(e.ownerId, e.x, e.y, e.button);
                onAction(ea);
            }
        };

        if (isCancel)
        {
            import dm.com.inputs.keyboards.key_name : KeyName;

            onKeyDown ~= (ref e) {
                if (isDisabled)
                {
                    return;
                }

                if (isFocus && e.keyName == KeyName.ESCAPE)
                {
                    if (onCancel)
                    {
                        onCancel();
                    }
                }
            };
        }

        if (isDefault)
        {
            import dm.com.inputs.keyboards.key_name : KeyName;

            onKeyDown ~= (ref e) {
                if (isDisabled)
                {
                    return;
                }

                if (isFocus && e.keyName == KeyName.RETURN)
                {
                    if (onDefault)
                    {
                        onDefault();
                    }
                }
            };
        }
    }

    override void addCreateIcon(string iconName)
    {
        super.addCreateIcon(iconName);
        if (_text && _text.text.length == 0)
        {
            _text.isLayoutManaged = false;
        }
        setInvalid;
    }

    void text(T)(T s) if (isSomeString!T)
    {
        dstring newText;

        static if (!is(T : immutable(dchar[])))
        {
            import std.conv : to;

            newText = s.to!dstring;
        }
        else
        {
            newText = s;
        }

        if (!_text)
        {
            _buttonText = newText;
            setInvalid;
            return;
        }

        _text.text = newText;
        if (!_text.isLayoutManaged)
        {
            _text.isLayoutManaged = true;
        }

        setInvalid;
    }

    dstring text()
    {
        if (_text)
        {
            return _text.text;
        }
        return _buttonText;
    }

    bool isSelected()
    {
        return _selected;
    }

    void isSelected(bool isSelected)
    {
        // if (isDisabled)
        // {
        //     return;
        // }
        _selected = isSelected;
        if (hover)
        {
            hover.isVisible = isSelected;
            setInvalid;
        }
    }

    override void dispose()
    {
        super.dispose;
        _buttonText = null;
        _selected = false;
        iconName = null;
    }

}
