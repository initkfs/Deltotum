module api.dm.gui.controls.indicators.color_bars.base_color_bar;

import api.dm.gui.controls.control: Control;
import api.dm.gui.controls.indicators.color_bars.color_bar_value: ColorBarValue;
import api.dm.kit.graphics.colors.rgba : RGBA;

/**
 * Authors: initkfs
 */

class BaseColorBar : Control
{
    ColorBarValue[] rangeData;

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
                ColorBarValue(step, theme.colorSuccess),
                ColorBarValue(step, theme.colorWarning),
                ColorBarValue(step, theme.colorDanger),
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
