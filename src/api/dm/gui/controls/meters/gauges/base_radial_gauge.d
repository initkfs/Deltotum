module api.dm.gui.controls.meters.gauges.base_radial_gauge;

import api.dm.gui.controls.meters.radial_min_max_value_meter : RadialMinMaxMeter;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.controls.meters.scales.statics.rscale_static : RScaleStatic;

/**
 * Authors: initkfs
 */
abstract class BaseRadialGauge : RadialMinMaxMeter!float
{
    RScaleStatic scale;
    bool isCreateScale = true;
    RScaleStatic delegate(RScaleStatic) onNewScale;
    void delegate(RScaleStatic) onConfiguredScale;
    void delegate(RScaleStatic) onCreatedScale;

    this(float diameter = 0, float minValue = 0, float maxValue = 1, float minAngleDeg = 0, float maxAngleDeg = 180)
    {
        super(diameter, minValue, maxValue, minAngleDeg, maxAngleDeg);

        import api.dm.kit.sprites2d.layouts.center_layout : CenterLayout;

        this.layout = new CenterLayout;
        layout.isAutoResize = true;
    }

    override void loadTheme()
    {
        super.loadTheme;

        if (diameter == 0)
        {
            diameter = theme.meterThumbDiameter * 2;
        }

        assert(diameter > 0);
        initSize(diameter, diameter);
    }

    RScaleStatic newScale()
    {
        auto scale = new RScaleStatic(diameter * 0.9, minAngleDeg, maxAngleDeg);
        scale.valueStep = 0.05;
        scale.majorTickStep = 5;
        return scale;
    }

    override void create()
    {
        super.create;

        if (!scale && isCreateScale)
        {
            auto s = newScale;
            scale = onNewScale ? onNewScale(s) : s;

            if (onConfiguredScale)
            {
                onConfiguredScale(scale);
            }

            addCreate(scale);

            if (onCreatedScale)
            {
                onCreatedScale(scale);
            }
        }
    }
}
