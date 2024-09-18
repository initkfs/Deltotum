module api.dm.gui.controls.scrolls.base_scroll;

import api.dm.kit.sprites.sprite : Sprite;
import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.textures.texture : Texture;

import api.dm.kit.sprites.shapes.shape : Shape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites.layouts.managed_layout : ManagedLayout;
import api.dm.kit.sprites.shapes.rectangle : Rectangle;
import api.math.alignment : Alignment;

/**
 * Authors: initkfs
 * TODO remove duplication with slider after testing 
 */
abstract class BaseScroll : Control
{
    double minValue;
    double maxValue;

    protected
    {
        double _value = 0;
    }

    double valueDelta = 0;

    void delegate(double) onValue;

    Sprite delegate() thumbFactory;

    protected
    {
        Sprite thumb;
    }

    this(double minValue = 0, double maxValue = 1.0)
    {
        this.minValue = minValue;
        this.maxValue = maxValue;

        this.layout = new ManagedLayout;

        isBorder = true;
    }

    override void initialize()
    {
        super.initialize;
    }

    override void create()
    {
        super.create;
    }

    double valueRange()
    {
        import Math = api.math;

        if (minValue == maxValue)
        {
            return 0;
        }

        const double range = minValue < maxValue ? (maxValue - minValue) : (minValue - maxValue);
        return range;
    }

    double value()
    {
        return _value;
    }

    void value(double v)
    {
        import Math = api.math;

        _value = Math.clamp(v, minValue, maxValue);
    }
}
