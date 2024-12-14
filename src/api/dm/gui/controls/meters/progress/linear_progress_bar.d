module api.dm.gui.controls.meters.progress.linear_progress_bar;

import api.dm.gui.controls.meters.progress.base_labeled_progress_bar : BaseLabeledProgressBar;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.containers.container : Container;
import api.math.orientation : Orientation;

/**
 * Authors: initkfs
 */
class LinearProgressBar : BaseLabeledProgressBar
{
    RGBA barColor;

    Container barContainer;
    double barSize = 0;

    Orientation orientation;

    this(double minValue = 0, double maxValue = 1.0, Orientation orientation = Orientation
            .horizontal)
    {
        super(minValue, maxValue);

        this.orientation = orientation;

        import api.dm.kit.sprites2d.layouts.vlayout;

        layout = new VLayout;
        layout.isAutoResize = true;
        layout.isAlignX = true;
    }

    override void loadTheme()
    {
        super.loadTheme;

        if (barColor == RGBA.init)
        {
            barColor = theme.colorAccent;
        }

        if (barSize == 0)
        {
            barSize = theme.meterThumbHeight;
        }

        if (orientation == Orientation.horizontal)
        {
            initHeight = barSize;
            if (width == 0)
            {
                initWidth = theme.controlDefaultWidth;
            }
        }
        else
        {
            initWidth = barSize;
            if (height == 0)
            {
                initHeight = theme.controlDefaultHeight;
            }
        }

    }

    override void create()
    {
        super.create;

        barContainer = new Container;
        if (orientation == Orientation.horizontal)
        {
            barContainer.resize(width, barSize);
        }
        else
        {
            barContainer.resize(barSize, height);
        }

        addCreate(barContainer);
    }

    override void drawContent()
    {
        super.drawContent;

        graphics.changeColor(barColor);
        scope (exit)
        {
            graphics.restoreColor;
        }

        //TODO vertical
        const bounds = barContainer.boundsRect;

        if (orientation == Orientation.horizontal)
        {
            const leftTopX = bounds.x + padding.left;
            const leftTopY = bounds.y + padding.top;

            const drawFullW = bounds.width - padding.right;
            const drawW = value * drawFullW / maxValue;
            const drawH = bounds.height - padding.height;

            graphics.rect(leftTopX, leftTopY, drawFullW, drawH);
            graphics.fillRect(leftTopX, leftTopY, drawW, drawH);
        }
        else
        {
            const leftBottomX = bounds.x + padding.left;
            const leftBottomY = bounds.bottom - padding.bottom;

            const drawFullH = bounds.height - padding.top;
            const drawH = value * drawFullH / maxValue;
            const drawW = bounds.width - padding.width;

            graphics.rect(leftBottomX, leftBottomY - drawFullH, drawW, drawFullH);
            graphics.fillRect(leftBottomX, leftBottomY - drawH, drawW, drawH);
        }

    }

    override protected void setProgressData(double oldV, double newV)
    {
        super.setProgressData(oldV, newV);
    }

}
