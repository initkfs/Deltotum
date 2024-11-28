module api.dm.gui.controls.switches.toggle_buttons.base_toggle_button;

import api.dm.kit.sprites.sprite : Sprite;
import api.dm.gui.controls.switches.base_biswitch : BaseBiswitch;
import api.dm.gui.controls.labeled : Labeled;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.sprites.textures.texture : Texture;
import api.dm.gui.controls.texts.text : Text;

/**
 * Authors: initkfs
 */
class BaseToggleButton : BaseBiswitch
{
    protected
    {
        RGBA lastLabelColor;
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

        if (layout)
        {
            layout.isDecreaseRootSize = true;
        }

        isBorder = true;
    }

    override void loadTheme()
    {
        loadLabeledTheme;
        loadToggleButtonTheme;
    }

    void loadToggleButtonTheme()
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

    import api.dm.kit.sprites.tweens : Tween;

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

        if (hasIcon)
        {
            if (auto iconTexture = cast(Texture) icon)
            {
                //TODO bool flag, sync?
                if (lastLabelColor == RGBA.init)
                {
                    lastLabelColor = iconTexture.color;
                }

                if (newState)
                {
                    iconTexture.color = newOnEffectIconColor(lastLabelColor);
                }
                else
                {
                    iconTexture.color = lastLabelColor;
                }
                iconTexture.setInvalid;
            }
        }

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

    RGBA newOnEffectIconColor(RGBA originalColor)
    {
        originalColor.contrast(80);
        return originalColor;
    }

    override Text newLabelText()
    {
        auto text = super.newLabelText;
        //TODO from theme
        if (!text.isBackground)
        {
            text.isBackground = true;
        }
        return text;
    }

    override void dispose()
    {
        super.dispose;
    }

}
