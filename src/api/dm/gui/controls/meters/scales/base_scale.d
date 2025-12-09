module api.dm.gui.controls.meters.scales.base_scale;

import api.dm.gui.controls.control : Control;
import api.dm.kit.graphics.colors.rgba : RGBA;

import Math = api.math;

/**
 * Authors: initkfs
 */
abstract class BaseScale : Control
{
    float tickMinorWidth = 0;
    float tickMinorHeight = 0;
    float tickMajorWidth = 0;
    float tickMajorHeight = 0;

    size_t majorTickStep = 5;

    bool isDrawFirstTick = true;
    bool isDrawLastTick = true;

    bool isFirstTickMajorTick = true;
    bool isLastTickMajorTick = true;

    bool isShowFirstLastLabel = true;
    bool isShowFirstLabelText = true;

    bool isInvertX;
    bool isInvertY;

    bool isDrawAxis = true;
    RGBA axisColor;
    RGBA tickMinorColor;
    RGBA tickMajorColor;

    size_t labelNumberPrecision = 2;
    size_t prefLabelGlyphWidth = 4;

    override void loadTheme()
    {
        super.loadTheme;
        loadBaseScaleTicksTheme;

        if (axisColor == RGBA.init)
        {
            axisColor = theme.colorAccent;
        }

        if (tickMinorColor == RGBA.init)
        {
            tickMinorColor = theme.colorAccent;
        }

        if (tickMajorColor == RGBA.init)
        {
            tickMajorColor = theme.colorDanger;
        }
    }

    void loadBaseScaleTicksTheme()
    {
        if (tickMinorWidth == 0)
        {
            tickMinorWidth = theme.meterTickMinorWidth;
        }

        if (tickMinorHeight == 0)
        {
            tickMinorHeight = theme.meterTickMinorHeight;
        }

        if (tickMajorWidth == 0)
        {
            tickMajorWidth = theme.meterTickMajorWidth;
        }

        if (tickMajorHeight == 0)
        {
            tickMajorHeight = theme.meterTickMajorHeight;
        }

        assert(tickMinorWidth > 0);
        assert(tickMinorHeight > 0);
        assert(tickMajorWidth > 0);
        assert(tickMajorHeight > 0);
    }

    dstring formatLabelValue(float value)
    {
        import std.conv : to;
        import std.math.rounding : trunc;

        if ((value - value.trunc) == 0)
        {
            return value.to!dstring;
        }

        import std.format : format;
        import std.math.operations : isClose;

        auto zeroPrec = 1.0 / (10 ^^ (labelNumberPrecision + 1));
        if (isClose(value, 0.0, 0.0, zeroPrec))
        {
            return "0"d;
        }

        return format("%.*f"d, labelNumberPrecision, value);
    }

    float tickMinWidth() => Math.min(tickMinorWidth, tickMajorWidth);
    float tickMaxWidth() => Math.max(tickMinorWidth, tickMajorWidth);

    float tickMinHeight() => Math.min(tickMinorHeight, tickMajorHeight);
    float tickMaxHeight() => Math.max(tickMinorHeight, tickMajorHeight);

}
