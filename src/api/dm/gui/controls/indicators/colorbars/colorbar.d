module api.dm.gui.controls.indicators.colorbars.colorbar;

import api.dm.gui.controls.indicators.colorbars.base_mono_colorbar: BaseMonoColorBar;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.controls.indicators.colorbars.colorbar_data : ColorBarData;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;

import Math = api.math;

/**
 * Authors: initkfs
 */

class ColorBar : BaseMonoColorBar
{

    this(float width = 0, float height = 0)
    {
        super(width, height);
    }

    override void loadTheme(){
        super.loadTheme;
        loadColorBarTheme;
    }

    void loadColorBarTheme(){

        if (width == 0)
        {
            initWidth = theme.controlDefaultWidth;
        }

        if (height == 0)
        {
            initHeight = theme.controlDefaultHeight / 3;
        }
    }

    override Sprite2d newBar()
    {
        import api.dm.kit.sprites2d.textures.texture2d : Texture2d;

        return new Texture2d(width, height);
    }

    override protected void createColorBar(Sprite2d bar)
    {
        import api.dm.kit.sprites2d.textures.texture2d : Texture2d;

        if (auto texture = cast(Texture2d) bar)
        {
            texture.createTargetRGBA32;

            texture.setRendererTarget;
            scope (exit)
            {
                texture.restoreRendererTarget;
            }

            graphic.clearTransparent;

            drawBar;

            return;
        }
    }

    void drawBar()
    {
        const rangeSum = rangeSum;

        float nextX = x;
        foreach (r; rangeData)
        {
            const rangeWidth = Math.round(r.value * width / rangeSum);
            graphic.fillRect(nextX, 0, rangeWidth, height, r.color);
            nextX += rangeWidth;
        }
    }
}
