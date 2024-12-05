module api.dm.gui.controls.meters.scrolls.mono_scroll;

import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.meters.scrolls.base_scroll : BaseScroll;
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

    double thumbWidth = 0;
    double thumbHeigth = 0;

    bool isCreateThumb = true;
    Sprite2d delegate(Sprite2d) onThumbCreate;
    void delegate(Sprite2d) onThumbCreated;

    bool isCreateOnPointerWheel = true;

    protected
    {
        Sprite2d thumb;
    }

    this(double minValue = 0, double maxValue = 1.0)
    {
        super(minValue, maxValue);
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

    override void loadTheme()
    {
        super.loadTheme;
        loadMonoScrollTheme;
    }

    void loadMonoScrollTheme()
    {
        if (thumbWidth == 0)
        {
            thumbWidth = theme.meterThumbWidth;
        }

        if (thumbHeigth == 0)
        {
            thumbHeigth = theme.meterThumbHeight;
        }
    }

    Sprite2d newThumb(double w, double h, double angle, GraphicStyle style)
    {
        return theme.shape(w, h, angle, style);
    }

    Sprite2d createThumb()
    {
        auto style = createFillStyle;
        auto shape = newThumb(thumbWidth, thumbHeigth, angle, style);
        return shape;
    }

    protected double wheelValue(double wheelDt) => _value;

    override void create()
    {
        super.create;

        if (!thumb && isCreateThumb)
        {
            auto th = createThumb;
            thumb = onThumbCreate ? onThumbCreate(th) : th;
            addCreate(thumb);
            if (onThumbCreated)
            {
                onThumbCreated(thumb);
            }
        }
    }

    double value() => _value;

    bool value(double v, bool isTriggerListeners = true)
    {
        if (!trySetValue(v))
        {
            return false;
        }

        if (isTriggerListeners)
        {
            triggerListeners(v);
        }

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

    bool setMinValue() => value = minValue;
    bool setMaxValue() => value = maxValue;

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
