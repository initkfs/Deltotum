module api.dm.gui.controls.progress.base_progress_bar;

import api.dm.gui.controls.control : Control;

/**
 * Authors: initkfs
 */
abstract class BaseProgressBar : Control
{
    double minValue;
    double maxValue;

    protected
    {
        double value = 0;
    }

    void delegate(double) onValue;

    this(double minValue = 0, double maxValue = 1.0)
    {
        if (minValue > maxValue)
        {
            import std.format : format;

            throw new Exception(format("The minimum value '%s' must be less than the maximum value '%s'", minValue, maxValue));
        }

        this.minValue = minValue;
        this.maxValue = maxValue;

        this.value = minValue;

        construct;
    }

    double progress()
    {
        return value;
    }

    bool progress(double v)
    {
        import Math = api.dm.math;

        auto newValue = Math.clamp(v, minValue, maxValue);
        if (value != newValue)
        {
            value = newValue;
            return true;
        }

        return false;
    }

    void setMin()
    {
        progress = minValue;
    }

    void setMax()
    {
        progress = maxValue;
    }
}
