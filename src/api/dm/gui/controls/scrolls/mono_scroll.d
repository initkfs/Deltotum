module api.dm.gui.controls.scrolls.mono_scroll;

import api.dm.kit.sprites.sprite : Sprite;
import api.dm.gui.controls.scrolls.base_scroll : BaseScroll;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 * TODO remove duplication with slider after testing 
 */
abstract class MonoScroll : BaseScroll
{
    protected
    {
        double _value = 0;
    }

    double valueDelta = 0;
    double valueStep = 0;

    void delegate(double)[] onValue;

    Sprite delegate() thumbFactory;

    protected
    {
        Sprite thumb;
    }

    this(double minValue = 0, double maxValue = 1.0)
    {
        super(minValue, maxValue);

        isBorder = true;
    }

    override void initialize()
    {
        super.initialize;

        if (valueStep == 0)
        {
            valueStep = valueRange / 20;
        }

        onPointerWheel ~= (ref e) {
            auto newValue = wheelValue(e.y);
            value(newValue);
        };
    }

    protected double wheelValue(double wheelDt)
    {
        return _value;
    }

    override void create()
    {
        super.create;
    }

    double value()
    {
        return _value;
    }

    bool value(double v)
    {

        if (!trySetValue(v))
        {
            return false;
        }

        triggerListeners(v);
        return true;
    }

    protected void triggerListeners(double v)
    {
        foreach (dg; onValue)
        {
            dg(v);
        }
    }

    bool trySetValue(double v)
    {
        import Math = api.math;

        import std.math.operations : isClose;
        import std.math.traits : isFinite;

        if (isClose(v, _value) || !isFinite(v))
        {
            return false;
        }

        if (v < minValue)
        {
            if (_value == minValue)
            {
                return false;
            }
            else
            {
                valueDelta = minValue - _value;
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
                valueDelta = maxValue - _value;
                _value = maxValue;
                return true;
            }
        }

        valueDelta = v - _value;
        _value = v;
        return true;
    }

    bool setMinValue()
    {
        if (!(value = minValue))
        {
            triggerListeners(minValue);
        }
        return true;
    }

    bool setMaxValue()
    {
        if (!(value = maxValue))
        {
            triggerListeners(maxValue);
        }
        return true;
    }

    GraphicStyle createThumbStyle()
    {
        auto style = theme.defaultStyle();
        if (!style.isNested)
        {
            style.lineColor = theme.colorAccent;
            style.fillColor = theme.colorAccent;
            style.isFill = true;
        }
        return style;
    }

    import api.core.utils.arrays : drop;

    bool removeOnValue(void delegate(double) dg)
    {
        return drop(onValue, dg);
    }

    override void dispose()
    {
        super.dispose;
        onValue = null;
    }
}
