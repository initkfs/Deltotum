module api.dm.gui.controls.switches.buttons.base_button;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.switches.base_biswitch : BaseBiswitch;
import api.dm.kit.sprites2d.shapes.shape2d : Shape2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.inputs.pointers.events.pointer_event : PointerEvent;
import api.dm.kit.sprites2d.shapes.rectangle : Rectangle;
import api.dm.gui.events.action_event : ActionEvent;
import api.dm.gui.controls.texts.text : Text;
import api.dm.kit.sprites2d.tweens.tween2d : Tween2d;

import std.traits : isSomeString;

/**
 * Authors: initkfs
 */
class BaseButton : BaseBiswitch
{
    enum defaultButtonText = "Button";
    void delegate(ref ActionEvent)[] onAction;

    bool isFixedButton;
    bool isAutolockButton;
    bool isLongPressButton;

    this(dstring text, string iconName, bool isCreateLayout = true)
    {
        this(text, 0, 0, iconName, 0, isCreateLayout);
    }

    this(dstring text, void delegate(ref ActionEvent) onAction, bool isCreateLayout = true)
    {
        this(text, 0, 0, null, 0, isCreateLayout);
        if (onAction)
        {
            this.onAction ~= onAction;
        }
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
        super(text, iconName, graphicsGap, isCreateLayout);

        initWidth = width;
        initHeight = height;

        isCreateHoverEffect = true;
        isCreateHoverEffectAnimation = true;
        isCreateActionEffect = true;
        isCreateActionEffectAnimation = true;

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
        super.loadTheme;
        loadBaseButtonTheme;
    }

    void loadBaseButtonTheme()
    {
        if (isSetNullWidthFromTheme && width == 0)
        {
            initWidth = theme.buttonWidth;
        }

        if (isSetNullHeightFromTheme && height == 0)
        {
            initHeight = theme.buttonHeight;
        }
    }

    override void create()
    {
        super.create;
    }

    override void delegate() newOnStopActionEffectAnimation()
    {
        //Autorelease buttons
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

        //Fixed and long press
        return () {

            if(_actionEffect.isVisible && isOn && isAutolockButton){
                return;
            }

            if (_actionEffect)
            {
                _actionEffectAnimation.isReverse = false;
                _actionEffect.isVisible = isOn;
            }
        };

    }

    override Tween2d newActionEffectAnimation()
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

    override void delegate(ref ActionEvent) newActionEffectStartBehaviour()
    {
        //Simple autoreleased buttons
        if (!isFixedButton || isLongPressButton)
        {
            return (ref e) {
                if (!isOn)
                {
                    //hysteresis
                    if (_actionEffectAnimation && _actionEffectAnimation.isRunning)
                    {
                        return;
                    }
                    isOn = true;
                    runActionListeners(e);
                }
            };
        }

        return (ref e) {
            
            if(isAutolockButton && isOn){
                return;
            }
            
            auto prevState = isOn;
            toggle;
            //Listeners may change state
            if (!prevState)
            {
                runActionListeners(e);
            }
        };
    }

    override void delegate(ref ActionEvent e) newActionEffectEndBehaviour()
    {
        return (ref e) {
            if (isDisabled)
            {
                return;
            }

            if(isAutolockButton && isOn){
                return;
            }

            if (isLongPressButton && isOn)
            {
                isOn = false;
            }
        };
    }

    override void runSwitchListeners(bool oldValue, bool newValue)
    {
        super.runSwitchListeners(oldValue, newValue);
    }

    void runActionListeners(ref ActionEvent ea)
    {
        if (onAction.length > 0)
        {
            foreach (dg; onAction)
            {
                if (dg)
                {
                    dg(ea);
                    if (ea.isConsumed)
                    {
                        break;
                    }
                }
            }
        }
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
        if(id == "first_button"){
            import std;
            writeln("STATE: ", oldState," ", newState);
        }
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
            }else {
                _actionEffect.opacity = 1;
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
    }

}
