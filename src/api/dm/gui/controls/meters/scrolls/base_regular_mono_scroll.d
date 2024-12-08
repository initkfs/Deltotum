module api.dm.gui.controls.meters.scrolls.base_regular_mono_scroll;

import api.dm.gui.controls.meters.scrolls.base_labeled_scroll: BaseLabeledScroll;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.meters.scrolls.base_scroll : BaseScroll;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 */
abstract class BaseRegularMonoScroll : BaseLabeledScroll
{
    double thumbWidth = 0;
    double thumbHeight = 0;

    this(double minValue = 0, double maxValue = 1.0)
    {
        super(minValue, maxValue);
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadMonoScrollTheme;
    }

    void loadMonoScrollTheme()
    {
        if (thumbWidth == 0)
        {
            thumbWidth = theme.meterThumbWidth;
        }

        if (thumbHeight == 0)
        {
            thumbHeight = theme.meterThumbHeight;
        }
    }

    Sprite2d newThumbShape(double w, double h, double angle, GraphicStyle style){
        return theme.shape(w, h, angle, style);
    }

    override Sprite2d newThumb()
    {
        auto style = createFillStyle;
        auto shape = newThumbShape(thumbWidth, thumbHeight, angle, style);
        return shape;
    }
}
