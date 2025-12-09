module api.dm.gui.controls.indicators.colorbars.base_colorbar;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.indicators.colorbars.colorbar_data : ColorBarData;
import api.dm.kit.graphics.colors.rgba : RGBA;

/**
 * Authors: initkfs
 */

class BaseColorBar : Control
{
    ColorBarData[] rangeData;

    this(float width = 0, float height = 0)
    {
        this._width = width;
        this._height = height;
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadBaseColorBarTheme;
    }

    void loadBaseColorBarTheme()
    {
        if (rangeData.length == 0)
        {
            auto step = 100.0 / 3;
            rangeData = [
                ColorBarData(step, theme.colorSuccess),
                ColorBarData(step, theme.colorWarning),
                ColorBarData(step, theme.colorDanger),
            ];
        }
    }

    float rangeSum()
    {
        float sum = 0;
        foreach (r; rangeData)
        {
            sum += r.value;
        }
        return sum;
    }

}
