module api.dm.gui.controls.meters.progress.base_progress_bar;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.meters.min_max_meter: MinMaxMeter;

import Math = api.math;

/**
 * Authors: initkfs
 */
abstract class BaseProgressBar : MinMaxMeter!double
{
    protected
    {
        double _value = 0;
    }

    double progressStep = 0.1;

    void delegate(double oldV, double newV)[] onOldNewValue;

    this(double minValue = 0, double maxValue = 1.0)
    {
        super(minValue, maxValue);
        _value = minValue;
    }

    void triggerListeners(double oldV, double newV)
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

    abstract protected void setProgressData(double oldV, double newV);

    double value() => _value;

    bool value(double newValue, bool isTriggerListeners = true)
    {
        if (_value == newValue)
        {
            return false;
        }
        double oldValue = _value;
        _value = Math.clamp(newValue, minValue, maxValue);
        if (isTriggerListeners)
        {
            triggerListeners(oldValue, _value);
        }

        setProgressData(oldValue, _value);

        return true;
    }
}
