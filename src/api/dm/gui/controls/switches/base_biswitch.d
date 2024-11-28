module api.dm.gui.controls.switches.base_biswitch;

import api.dm.gui.controls.labeled : Labeled;
import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.sprites.textures.texture : Texture;

/**
 * Authors: initkfs
 */
class BaseBiswitch : Labeled
{
    bool isFixed;

    protected
    {
        bool _state;
        RGBA lastLabelColor;
    }

    this(double width = 0, double height = 0, string iconName = null, double graphicsGap = 0, dstring labelText = null, bool isCreateLayout = true)
    {
        super(width, height, iconName, graphicsGap, labelText, isCreateLayout);
    }

    void delegate(bool, bool)[] onOldNewValue;

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

        if (isFixed && hasIcon)
        {
            if (auto iconTexture = cast(Texture) icon)
            {
                 //TODO bool flag, sync?
                if (lastLabelColor == RGBA.init)
                {
                    lastLabelColor = iconTexture.color;
                }

                if (_state)
                {
                    iconTexture.color = newOnIconColor(lastLabelColor);
                }
                else
                {
                    iconTexture.color = lastLabelColor;
                }
                iconTexture.setInvalid;

            }
        }

        if (isCreated && isRunListeners)
        {
            runSwitchListeners(oldValue, _state);
        }

        return true;
    }

    RGBA newOnIconColor(RGBA originalColor)
    {
        originalColor.contrast(80);
        return originalColor;
    }

    import api.dm.gui.controls.texts.text: Text;

    override Text newLabelText()
    {
        auto text = super.newLabelText;
        if(!isFixed){
            return text;
        }

        text.isBackground = true;
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
}
