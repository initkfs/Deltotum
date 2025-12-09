module api.dm.gui.controls.meters.scrolls.base_mono_scroll;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.meters.scrolls.base_scroll : BaseScroll;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

import api.math.geom2.vec2 : Vec2d;

/**
 * Authors: initkfs
 * TODO remove duplication with slider after testing 
 */
abstract class BaseMonoScroll : BaseScroll
{
    protected
    {
        float _value = 0;
    }

    float valueDelta = 0;
    float valueStep = 0;

    float delegate(float) onNewWheelDY;
    float delegate(float) onNewThumbX;
    float delegate(float) onNewThumbY;

    void delegate(float)[] onValue;

    bool isCreateThumb = true;
    Sprite2d delegate(Sprite2d) onNewThumb;
    void delegate(Sprite2d) onConfiguredThumb;
    void delegate(Sprite2d) onCreatedThumb;

    bool isCreateOnPointerWheel = true;

    Sprite2d thumb;

    this(float minValue = 0, float maxValue = 1.0)
    {
        super(minValue, maxValue);

        import api.dm.kit.sprites2d.layouts.center_layout : CenterLayout;

        layout = new CenterLayout;
        layout.isAutoResize = true;

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
            float dy = !onNewWheelDY ? e.y : onNewWheelDY(e.y);
            auto newValue = wheelValue(dy);
            value(newValue);
        };
    }

    abstract Sprite2d newThumb();

    protected float wheelValue(float wheelDt) => _value;

    override void create()
    {
        super.create;

        if (!thumb && isCreateThumb)
        {
            auto th = newThumb;
            thumb = onNewThumb ? onNewThumb(th) : th;

            thumb.isResizedByParent = false;
            thumb.isLayoutMovable = false;

            if (onConfiguredThumb)
            {
                onConfiguredThumb(thumb);
            }

            addCreate(thumb);
            
            if (onCreatedThumb)
            {
                onCreatedThumb(thumb);
            }

            auto dragListener = newOnThumbDragXY;
            if (dragListener)
            {
                thumb.isDraggable = true;
                thumb.onDragXY = (x, y) {
                    float newX = !onNewThumbX ? x : onNewThumbX(x);
                    float newY = !onNewThumbY ? y : onNewThumbY(y);
                    return dragListener(newX, newY);
                };
            }
        }
    }

    bool delegate(float, float) newOnThumbDragXY()
    {
        return (x, y) { return false; };
    }

    float value() => _value;

    bool value(float v, bool isTriggerListeners = true)
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

    protected void triggerListeners(float v)
    {
        foreach (dg; onValue)
        {
            dg(v);
        }
    }

    bool trySetValue(float v)
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

    bool removeOnValue(void delegate(float) dg)
    {
        return drop(onValue, dg);
    }

    override void dispose()
    {
        super.dispose;
        onValue = null;
    }
}
