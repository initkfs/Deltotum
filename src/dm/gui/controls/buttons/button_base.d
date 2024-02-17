module dm.gui.controls.buttons.button_base;

import dm.kit.sprites.sprite : Sprite;
import dm.gui.controls.labeled : Labeled;
import dm.kit.sprites.shapes.shape : Shape;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;
import dm.kit.sprites.shapes.rectangle : Rectangle;
import dm.gui.events.action_event : ActionEvent;
import dm.kit.sprites.animations.object.value_transition : ValueTransition;
import dm.kit.sprites.animations.object.property.opacity_transition : OpacityTransition;
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

    bool isCreateHoverFactory = true;
    bool isCreateClickEffectFactory = true;
    bool isCreateClickEffectAnimationFactory = true;
    bool isCreateTextFactory = true;

    Sprite delegate(double, double) hoverFactory;
    Sprite delegate() clickEffectFactory;
    ValueTransition delegate() clickEffectAnimationFactory;
    Text delegate() textFactory;

    bool isCancel;
    void delegate() onCancel;

    bool isDefault;
    void delegate() onDefault;

    protected
    {
        Sprite hover;
        Sprite clickEffect;
        ValueTransition clickEffectAnimation;

        Text _text;

        dstring _buttonText;
        bool _selected;
        string iconName;
    }

    string idControlBackground = "btn_background";
    string idControlHover = "btn_hover";
    string idControlClick = "btn_click";

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

        if (!hoverFactory && isCreateHoverFactory)
        {
            hoverFactory = createHoverFactory;
        }

        if (!clickEffectFactory && isCreateClickEffectFactory)
        {
            clickEffectFactory = createClickEffectFactory;
        }

        if (!textFactory && isCreateTextFactory)
        {
            textFactory = createTextFactory;
        }

        if (!clickEffectAnimationFactory && isCreateClickEffectAnimationFactory)
        {
            clickEffectAnimationFactory = createClickEffectAnimationFactory;
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

    Sprite delegate(double, double) createHoverFactory()
    {
        return (width, height) {
            assert(graphics.theme);

            GraphicStyle style;
            if (auto parentStyle = ownOrParentStyle)
            {
                style = *parentStyle;
            }
            else
            {
                style = graphics.theme.defaultStyle;
                style.lineColor = graphics
                    .theme.colorHover;
                style.fillColor = graphics.theme.colorHover;
                style.isFill = true;
            }

            Sprite newHover = graphics.theme.background(width, height, &style);
            newHover.id = idControlHover;
            newHover.isLayoutManaged = false;
            newHover.isResizedByParent = true;
            newHover.isVisible = false;
            return newHover;
        };
    }

    Sprite delegate() createClickEffectFactory()
    {
        return () {
            assert(graphics.theme);

            GraphicStyle style;
            if (auto parentStyle = ownOrParentStyle)
            {
                style = *parentStyle;
            }
            else
            {
                style = graphics.theme.defaultStyle;
                style.lineColor = graphics
                    .theme.colorAccent;
                style.fillColor = graphics.theme.colorAccent;
                style.isFill = true;
            }

            Sprite click = graphics.theme.background(width, height, &style);
            click.id = idControlClick;
            click.isLayoutManaged = false;
            click.isResizedByParent = true;
            click.isVisible = false;

            return click;
        };
    }

    ValueTransition delegate() createClickEffectAnimationFactory()
    {
        return () {
            if (!clickEffect)
            {
                logger.error("Cannot create click effect animation, click effect is null");
                return null;
            }
            auto clickEffectAnimation = new OpacityTransition(clickEffect, 50);
            clickEffectAnimation.isLayoutManaged = false;
            clickEffectAnimation.isCycle = false;
            clickEffectAnimation.isInverse = true;
            clickEffectAnimation.onEnd = () {
                if (clickEffect !is null)
                {
                    clickEffect.isVisible = false;
                }
            };
            return clickEffectAnimation;
        };
    }

    override void create()
    {
        super.create;

        if (hoverFactory)
        {
            hover = hoverFactory(width, height);
            if (hover)
            {
                addCreate(hover);
            }
            else
            {
                logger.error("Hover factory did not return the object");
            }
            hover.opacity = graphics.theme.opacityHover;
        }

        if (clickEffectFactory)
        {
            clickEffect = clickEffectFactory();
            if (clickEffect)
            {
                addCreate(clickEffect);
            }
            else
            {
                logger.error("Click effect factory did not return the object");
            }
            clickEffect.opacity = 0;
        }

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

        if (clickEffect)
        {
            clickEffectAnimation = clickEffectAnimationFactory();
            if (clickEffectAnimation)
            {
                addCreate(clickEffectAnimation);
            }
            else
            {
                logger.error("Click effect animation factory did not return the object");
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

            if (clickEffect && !clickEffect.isVisible)
            {
                clickEffect.isVisible = true;
                if (clickEffectAnimation && !clickEffectAnimation.isRunning)
                {
                    clickEffectAnimation.run;
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
