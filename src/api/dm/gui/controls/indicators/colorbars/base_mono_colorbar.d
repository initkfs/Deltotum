module api.dm.gui.controls.indicators.colorbars.base_mono_colorbar;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.indicators.colorbars.base_colorbar : BaseColorBar;
import api.dm.gui.controls.indicators.colorbars.colorbar_data : ColorBarData;
import api.dm.kit.graphics.colors.rgba : RGBA;

/**
 * Authors: initkfs
 */

class BaseMonoColorBar : BaseColorBar
{
    Sprite2d bar;
    bool isCreateBar = true;
    Sprite2d delegate(Sprite2d) onNewBar;
    void delegate(Sprite2d) onConfiguredBar;
    void delegate(Sprite2d) onCreatedBar;

    this(double width = 0, double height = 0)
    {
        this._width = width;
        this._height = height;
    }

    abstract
    {
        Sprite2d newBar();
        protected void createColorBar(Sprite2d);
    }

    override void create()
    {
        super.create;

        if (!bar && isCreateBar)
        {
            auto b = newBar;
            bar = !onNewBar ? b : onNewBar(b);

            buildInit(bar);

            if (onConfiguredBar)
            {
                onConfiguredBar(bar);
            }

            createColorBar(bar);

            if (!bar.parent)
            {
                addCreate(bar);
            }

            if (onCreatedBar)
            {
                onCreatedBar(bar);
            }
        }
    }

}
