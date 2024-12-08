module api.dm.gui.controls.indicators.range_bars.color_range_bar;

import api.dm.gui.controls.control: Control;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.sprites.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;

/**
 * Authors: initkfs
 */
struct RangeData
{
    double value = 0;
    RGBA color;
}

class ColorRangeBar : Control
{

    Sprite2d bar;

    RangeData[] rangeData;

    this(double width = 0, double height = 0)
    {
        this._width = width;
        this._height = height;

        import api.dm.kit.sprites.sprites2d.layouts.center_layout : CenterLayout;

        layout = new CenterLayout;
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadControlSizeTheme;

        if (rangeData.length == 0)
        {
            auto step = 100 / 3;
            rangeData = [
                RangeData(step, theme.colorSuccess),
                RangeData(step, theme.colorWarning),
                RangeData(step, theme.colorDanger),
            ];
        }
    }

    override void create()
    {
        super.create;

        Texture2d rangeShape = new Texture2d(width, height);
        buildInit(rangeShape);
        rangeShape.createTargetRGBA32;

        rangeShape.setRendererTarget;
        scope (exit)
        {
            rangeShape.restoreRendererTarget;
        }

        const rangeSum = colorRangeSum;

        double nextX = x;
        foreach (r; rangeData)
        {
            const rangeWidth = r.value * width / rangeSum;
            graphics.fillRect(nextX, 0, rangeWidth, height, r.color);
            nextX += rangeWidth;
        }

        addCreate(rangeShape);
    }

    double colorRangeSum()
    {
        double sum = 0;
        foreach (r; rangeData)
        {
            sum += r.value;
        }
        return sum;
    }

}
