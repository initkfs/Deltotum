module api.dm.gui.controls.meters.min_max_value_meter;

import api.dm.gui.controls.meters.min_max_meter : MinMaxMeter;

/**
 * Authors: initkfs
 */
abstract class MinMaxValueMeter(ValueType) : MinMaxMeter!ValueType
{
    protected
    {
        ValueType _value = 0;
    }

    float lastValueDelta = 0;

    void delegate(ValueType, ValueType)[] onChangeOldNew;

    this(ValueType minValue, ValueType maxValue)
    {
        super(minValue, maxValue);
    }

    ValueType value() => _value;

    void updateState()
    {
    }

    bool value(ValueType v, bool isTriggerListeners = true)
    {
        auto oldValue = _value;
        if (!trySetValue(v))
        {
            return false;
        }

        updateState;

        if (isTriggerListeners)
        {
            triggerListeners(oldValue, v);
        }

        return true;
    }

    void triggerListeners(ValueType oldv, ValueType newv)
    {
        foreach (dg; onChangeOldNew)
        {
            dg(oldv, newv);
        }
    }

    bool trySetValue(ValueType v)
    {
        static if (__traits(isFloating, ValueType))
        {
            import Math = api.math;

            import std.math.operations : isClose;
            import std.math.traits : isFinite;

            if (isClose(v, _value) || !isFinite(v))
            {
                return false;
            }

            if (minValue == 0 && isClose(v, 0.0, 0.0, float.epsilon))
            {
                if (_value != minValue)
                {
                    lastValueDelta = minValue - _value;
                    _value = minValue;
                    return true;
                }
                else
                {
                    return false;
                }
            }

            if (maxValue == 0 && isClose(v, 0.0, 0.0, float.epsilon))
            {
                if (_value != maxValue)
                {
                    lastValueDelta = maxValue - _value;
                    _value = maxValue;
                    return true;
                }
                else
                {
                    return false;
                }
            }
        }
        else
        {
            if (v == _value)
            {
                return false;
            }
        }

        if (v < minValue)
        {
            if (_value == minValue)
            {
                return false;
            }
            else
            {
                lastValueDelta = minValue - _value;
                _value = minValue;
                return true;
            }
        }

        if (v > maxValue)
        {
            if (_value == maxValue)
            {
                return false;
            }
            else
            {
                lastValueDelta = maxValue - _value;
                _value = maxValue;
                return true;
            }
        }

        lastValueDelta = v - _value;
        _value = v;
        return true;
    }
}
