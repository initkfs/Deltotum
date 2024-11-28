module api.dm.gui.controls.switches.base_biswitch;

import api.dm.gui.controls.labeled : Labeled;
import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
class BaseBiswitch : Labeled
{
    void delegate(bool, bool)[] onOldNewValue;

    protected
    {
        bool _state;
    }

    this(double width = 0, double height = 0, dstring labelText = null, string iconName = null, double graphicsGap = 0, bool isCreateLayout = true)
    {
        super(width, height, labelText, iconName, graphicsGap, isCreateLayout);
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

    void switchContentState(bool oldState, bool newState) {

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
