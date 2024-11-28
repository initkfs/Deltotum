module api.dm.gui.controls.switches.locks.base_lock_switch;

import api.dm.kit.sprites.sprite : Sprite;
import api.dm.gui.controls.switches.base_biswitch : BaseBiswitch;
import api.dm.gui.controls.labeled : Labeled;
import api.dm.kit.sprites.tweens : Tween;

/**
 * Authors: initkfs
 */
class BaseLockSwitch : BaseBiswitch
{
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

        if (layout)
        {
            layout.isDecreaseRootSize = true;
        }

        isBorder = true;

        isSwitchIcon = true;
    }

    override void loadTheme()
    {
        loadLabeledTheme;
        loadLockButtonTheme;
    }

    void loadLockButtonTheme()
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
    }

    override Tween newActionEffectAnimation()
    {
        auto anim = super.newActionEffectAnimation;
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
        return () { toggle; };
    }

    override protected void switchContentState(bool oldState, bool newState)
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
