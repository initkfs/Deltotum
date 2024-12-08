module api.dm.gui.controls.indicators.range_bars.color_range_bar;

import api.dm.gui.controls.indicators.range_bars.base_color_range_bar: BaseColorRangeBar;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.controls.indicators.range_bars.color_range: ColorRange;
import api.dm.kit.sprites.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;

/**
 * Authors: initkfs
 */

class ColorRangeBar : BaseColorRangeBar
{
    Sprite2d bar;

    this(double width = 0, double height = 0)
    {
        super(width, height);
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
