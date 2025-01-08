module api.dm.gui.controls.switches.base_biswitch;

import api.dm.gui.controls.labeled : Labeled;
import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;

import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.gui.controls.texts.text : Text;

/**
 * Authors: initkfs
 */
class BaseBiswitch : Labeled
{
    void delegate(bool, bool)[] onOldNewValue;

    bool isSwitchIcon;
    bool isSwitchLabel;

    protected
    {
        bool _state;
        RGBA lastLabelColor;
    }

    this(dstring labelText = null, string iconName = null, double graphicsGap = 0, bool isCreateLayout = true)
    {
        super(labelText, iconName, graphicsGap, isCreateLayout);
    }

    override void create()
    {
        super.create;

        switchContentState(_state, _state);
    }

    bool toggle(bool isRunListeners = true) => isOn(!_state, isRunListeners);

    bool isOff() => !isOn;

    bool isOn() => _state;

    bool isOn(bool value, bool isRunListeners = true)
    {
        if (value == _state)
        {
            return false;
        }

        const bool oldValue = _state;
        _state = value;

        if (isCreated)
        {
            switchContentState(oldValue, _state);

            if (isRunListeners)
            {
                runSwitchListeners(oldValue, _state);
            }
        }

        return true;
    }

    void switchContentState(bool oldState, bool newState)
    {
        if (isSwitchIcon && hasIcon)
        {
            if (auto iconTexture = cast(Texture2d) icon)
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
    }

    RGBA newOnEffectIconColor(RGBA originalColor)
    {
        originalColor.contrast(80);
        return originalColor;
    }

    override Text newLabelText()
    {
        auto text = super.newLabelText;
        if (!isSwitchLabel)
        {
            return text;
        }
        //TODO from theme
        if (!text.isBackground)
        {
            text.isBackground = true;
        }
        return text;
    }

    void runSwitchListeners(bool oldValue, bool newValue)
    {
        if (onOldNewValue.length > 0)
        {
            foreach (dg; onOldNewValue)
            {
                dg(oldValue, newValue);
            }
        }
    }

    void isSwitchContent(bool value)
    {
        isSwitchIcon = value;
        isSwitchLabel = value;
    }
}
