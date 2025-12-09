module api.dm.gui.controls.meters.progress.base_progress_bar;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.meters.min_max_meter: MinMaxMeter;

import Math = api.math;

/**
 * Authors: initkfs
 */
abstract class BaseProgressBar : MinMaxMeter!float
{
    protected
    {
        float _value = 0;
    }

    float progressStep = 0.1;

    void delegate(float oldV, float newV)[] onOldNewValue;

    this(float minValue = 0, float maxValue = 1.0)
    {
        super(minValue, maxValue);
        _value = minValue;
    }

    void triggerListeners(float oldV, float newV)
    {
        if (onOldNewValue.length > 0)
        {
            foreach (dg; onOldNewValue)
            {
                assert(dg);
                dg(oldV, newV);
            }
        }
    }

    abstract protected void setProgressData(float oldV, float newV);

    float value() => _value;

    bool value(float newValue, bool isTriggerListeners = true)
    {
        if (_value == newValue)
        {
            return false;
        }
        float oldValue = _value;
        _value = Math.clamp(newValue, minValue, maxValue);
        if (isTriggerListeners)
        {
            triggerListeners(oldValue, _value);
        }

        setProgressData(oldValue, _value);

        return true;
    }
}
