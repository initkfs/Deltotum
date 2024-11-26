module api.dm.gui.controls.toggles.base_bitoggle;

import api.dm.gui.controls.labeled : Labeled;
import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
class BaseBitoggle : Labeled
{
    protected
    {
        bool _state;
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

        if (isCreated && isRunListeners)
        {
            runToggleListeners(oldValue, _state);
        }

        return true;
    }

    void runToggleListeners(bool oldValue, bool newValue)
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
