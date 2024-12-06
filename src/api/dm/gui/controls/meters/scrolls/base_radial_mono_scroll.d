module api.dm.gui.controls.meters.scrolls.base_radial_mono_scroll;

import api.dm.gui.controls.meters.scrolls.base_labeled_scroll : BaseLabeledScroll;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.meters.scrolls.base_scroll : BaseScroll;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

import Math = api.math;

/**
 * Authors: initkfs
 */
abstract class BaseRadialMonoScroll : BaseLabeledScroll
{
    double thumbDiameter = 0;
    size_t thumbSides = 10;

    this(double minValue = 0, double maxValue = 1.0)
    {
        super(minValue, maxValue);
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadBaseRadialMonoScrollTheme;
    }

    void loadBaseRadialMonoScrollTheme()
    {
        if (thumbDiameter == 0)
        {
            thumbDiameter = theme.meterThumbDiameter;
        }

        if (_width == 0)
        {
            _width = thumbDiameter * 1.5;
        }

        if (_height == 0)
        {
            _height = thumbDiameter * 1.5;
        }
    }
}
