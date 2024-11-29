module api.dm.gui.controls.switches.buttons.base_button;

import api.dm.kit.sprites.sprite : Sprite;
import api.dm.gui.controls.switches.base_biswitch : BaseBiswitch;
import api.dm.kit.sprites.shapes.shape : Shape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites.shapes.rectangle : Rectangle;
import api.dm.gui.events.action_event : ActionEvent;
import api.dm.gui.controls.texts.text : Text;
import api.dm.kit.sprites.tweens : Tween;

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

    bool isFixedButton;
    bool isLongPressButton = true;

    this(dstring text, string iconName, bool isCreateLayout = true)
    {
        this(text, 0, 0, iconName, 0, isCreateLayout);
    }

    this(dstring text, void delegate(ref ActionEvent) onAction, bool isCreateLayout = true)
    {
        this(text, 0, 0, null, 0, isCreateLayout);
        this.onAction ~= onAction;
    }

    this(
        dstring text,
        double width = 0,
        double height = 0,
        string iconName = null,
        double graphicsGap = 0,
        bool isCreateLayout = true
    )
    {
        super(width, height, text, iconName, graphicsGap, isCreateLayout);

        isCreateHover = true;
        isCreateHoverAnimation = true;
        isCreateActionEffect = true;
        isCreateActionAnimation = true;

        isCreateInteractiveListeners = true;

        isBorder = true;
    }

    override void initialize()
    {
        super.initialize;

        if (isFixedButton)
        {
            // if (layout)
            // {
            //     layout.isDecreaseRootSize = true;
            // }
            isSwitchIcon = true;
        }
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

            if (isDisabled)
            {
                return;
            }

            if (isLongPressButton && isOn)
            {
                isOn = false;
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

    override void delegate() newOnEndActionEffectAnimation()
    {
        if (!isFixedButton && !isLongPressButton)
        {
            return () {
                if (_actionEffect)
                {
                    _actionEffect.isVisible = false;
                }

                isOn = false;
            };
        }

        //Fixed and autorelease
        return () {
            if (_actionEffect)
            {
                _actionEffectAnimation.isReverse = false;
                _actionEffect.isVisible = isOn;
            }
        };

    }

    override Tween newActionEffectAnimation()
    {
        auto anim = super.newActionEffectAnimation;
        if (!isFixedButton && !isLongPressButton)
        {
            return anim;
        }

        if (anim.isOneShort)
        {
            anim.isOneShort = false;
        }
        return anim;
    }

    override void delegate() newActionEffectBehaviour()
    {
        if (!isFixedButton || isLongPressButton)
        {
            return () {
                if (!isOn)
                {
                    isOn = true;
                }
            };
        }

        return () { toggle; };
    }

    override void runSwitchListeners(bool oldValue, bool newValue)
    {
        super.runSwitchListeners(oldValue, newValue);
    }

    override protected void switchContentState(bool oldState, bool newState)
    {
        if (isFixedButton || isLongPressButton)
        {
            switchFixedContentState(oldState, newState);
        }
        else
        {
            switchNonFixedContentState(oldState, newState);
        }
    }

    protected void switchNonFixedContentState(bool oldState, bool newState)
    {
        super.switchContentState(oldState, newState);

        if (newState)
        {
            if (_actionEffect)
            {
                _actionEffect.isVisible = true;
            }

            if (_actionEffectAnimation)
            {
                if (_actionEffectAnimation.isRunning)
                {
                    _actionEffectAnimation.stop;
                }

                if (_actionEffect)
                {
                    _actionEffect.opacity = 0;
                }

                _actionEffectAnimation.run;
            }
        }
        else
        {
            if (_actionEffect && !_actionEffectAnimation)
            {
                _actionEffect.isVisible = false;
            }
        }
    }

    protected void switchFixedContentState(bool oldState, bool newState)
    {
        super.switchContentState(oldState, newState);

        if (newState)
        {
            import std;
            writeln("SWITCH TRUE");
            if (_actionEffectAnimation)
            {
                if (_actionEffectAnimation.isRunning)
                {
                    _actionEffectAnimation.stop;
                }

                if (_actionEffect)
                {
                    _actionEffect.opacity = 0;
                }

                _actionEffectAnimation.run;
            }

        }
        else
        {
            import std;
            writeln("SWITCH FALSE");
            if (_actionEffectAnimation)
            {
                if (_actionEffectAnimation.isRunning)
                {
                    _actionEffectAnimation.stop;
                }
                _actionEffectAnimation.isReverse = true;
                _actionEffectAnimation.run;
            }
        }
    }

    override void dispose()
    {
        super.dispose;

        onAction = null;
        onCancel = null;
        onDefault = null;
    }

}