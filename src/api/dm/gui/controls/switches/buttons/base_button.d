module api.dm.gui.controls.switches.buttons.base_button;

import api.dm.kit.sprites.sprite : Sprite;
import api.dm.gui.controls.switches.base_biswitch : BaseBiswitch;
import api.dm.gui.controls.labeled : Labeled;
import api.dm.kit.sprites.shapes.shape : Shape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites.shapes.rectangle : Rectangle;
import api.dm.gui.events.action_event : ActionEvent;
import api.dm.gui.controls.texts.text : Text;
import api.dm.kit.sprites.textures.texture : Texture;
import api.dm.kit.graphics.colors.rgba : RGBA;

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
class BaseButton : BaseBiswitch
{
    enum defaultButtonText = "Button";
    void delegate(ref ActionEvent)[] onAction;

    bool isCancel;
    void delegate()[] onCancel;

    bool isDefault;
    void delegate()[] onDefault;

    bool isFixed = true;

    this(dstring text, string iconName, bool isCreateLayout = true)
    {
        this(text, 0, 0, 0, iconName, isCreateLayout);
    }

    this(dstring text, void delegate(ref ActionEvent) onAction, bool isCreateLayout = true)
    {
        this(text, 0, 0, 0, null, isCreateLayout);
        this.onAction ~= onAction;
    }

    this(
        dstring text,
        double width = 0,
        double height = 0,
        double graphicsGap = 0,
        string iconName = null,
        bool isCreateLayout = true
    )
    {
        super(width, height, iconName, graphicsGap, text, isCreateLayout);

        isCreateHover = true;
        isCreateHoverAnimation = true;
        isCreateActionEffect = true;
        isCreateActionAnimation = true;

        isCreateInteractiveListeners = true;

        isBorder = true;
    }

    override void loadTheme()
    {
        loadLabeledTheme;
        loadBaseButtonTheme;
    }

    void loadBaseButtonTheme()
    {
        if (isSetNullWidthFromTheme && _width == 0)
        {
            _width = theme.buttonWidth;
        }

        if (isSetNullHeightFromTheme && _height == 0)
        {
            _height = theme.buttonHeight;
        }
    }

    override void create()
    {
        super.create;

        onPointerUp ~= (ref e) {

            if (isDisabled || _selected)
            {
                return;
            }

            if (onAction.length > 0)
            {
                auto ea = ActionEvent(e.ownerId, e.x, e.y, e.button);
                foreach (dg; onAction)
                {
                    dg(ea);
                    if (ea.isConsumed)
                    {
                        break;
                    }
                }
            }
        };

        if (isCancel)
        {
            import api.dm.com.inputs.com_keyboard : ComKeyName;

            onKeyDown ~= (ref e) {
                if (isDisabled)
                {
                    return;
                }

                if (isFocus && e.keyName == ComKeyName.ESCAPE)
                {
                    foreach (dg; onCancel)
                    {
                        dg();
                    }
                }
            };
        }

        if (isDefault)
        {
            import api.dm.com.inputs.com_keyboard : ComKeyName;

            onKeyDown ~= (ref e) {
                if (isDisabled)
                {
                    return;
                }

                if (isFocus && e.keyName == ComKeyName.RETURN)
                {
                    foreach (dg; onDefault)
                    {
                        dg();
                    }
                }
            };
        }
    }

    import api.dm.kit.sprites.tweens : Tween;

    override Tween newActionEffectAnimation()
    {
        auto anim = super.newActionEffectAnimation;
        if (!isFixed)
        {
            return anim;
        }

        if (anim.isOneShort)
        {
            anim.isOneShort = false;
        }
        return anim;
    }

    override void delegate() newOnEndActionEffectAnimation()
    {
        return () {
            if (_actionEffect)
            {
                _actionEffectAnimation.isReverse = false;
                _actionEffect.isVisible = isOn;
            }
        };
    }

    override void delegate() newActionEffectBehaviour()
    {
        return () {

            if (!isOn)
            {
                isOn = true;

                if (_actionEffect)
                {
                    if (_actionEffectAnimation && _actionEffectAnimation.isRunning)
                    {
                        _actionEffectAnimation.stop;
                    }

                    _actionEffect.opacity = 0;
                    _actionEffectAnimation.run;
                }

            }
            else
            {
                isOn = false;

                if (_actionEffect)
                {
                    if (_actionEffectAnimation && _actionEffectAnimation.isRunning)
                    {
                        _actionEffectAnimation.stop;
                    }

                    _actionEffectAnimation.isReverse = true;
                    _actionEffectAnimation.run;
                }
            }

        };
    }

    override void addCreateIcon(string iconName)
    {
        super.addCreateIcon(iconName);
        if (_label && _label.text.length == 0)
        {
            _label.isLayoutManaged = false;
            _label.isVisible = false;
        }
        setInvalid;
    }

    override void dispose()
    {
        super.dispose;

        onAction = null;
        onCancel = null;
        onDefault = null;
    }

}
