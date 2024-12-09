module api.dm.gui.controls.indicators.range_bars.base_color_range_bar;

import api.dm.gui.controls.control: Control;
import api.dm.gui.controls.indicators.range_bars.color_range: ColorRange;
import api.dm.kit.graphics.colors.rgba : RGBA;

/**
 * Authors: initkfs
 */

class BaseColorRangeBar : Control
{
    ColorRange[] rangeData;

    this(double width = 0, double height = 0)
    {
        this._width = width;
        this._height = height;
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadControlSizeTheme;

        if (rangeData.length == 0)
        {
            auto step = 100 / 3;
            rangeData = [
                ColorRange(step, theme.colorSuccess),
                ColorRange(step, theme.colorWarning),
                ColorRange(step, theme.colorDanger),
            ];
        }
    }

    double rangeSum()
    {
        double sum = 0;
        foreach (r; rangeData)
        {
            sum += r.value;
        }
        return sum;
    }

}
