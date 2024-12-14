module api.dm.gui.controls.meters.progress.linear_progress_bar;

import api.dm.gui.controls.meters.progress.base_labeled_progress_bar: BaseLabeledProgressBar;
import api.dm.kit.graphics.colors.rgba: RGBA;
import api.dm.gui.containers.container: Container;

/**
 * Authors: initkfs
 */
class LinearProgressBar : BaseLabeledProgressBar
{
    RGBA barColor;

    Container barContainer;
    double barSize = 0;

    this(double minValue = 0, double maxValue = 1.0)
    {
        super(minValue, maxValue);

        import api.dm.kit.sprites2d.layouts.vlayout;
        layout = new VLayout;
        layout.isAutoResize = true;
        layout.isAlignX = true;
    }

    override void loadTheme(){
        super.loadTheme;

        if(barColor == RGBA.init){
            barColor = theme.colorAccent;
        }

        if(barSize == 0){
            barSize = theme.meterThumbHeight;
            initHeight = barSize;
        }

        if(width == 0){
            initWidth = theme.controlDefaultWidth;
        }
    }

    override void create(){
        super.create;

        barContainer = new Container;
        barContainer.width = width;
        barContainer.height = barSize;
        addCreate(barContainer);
    }


    override void drawContent(){
        super.drawContent;

        graphics.changeColor(barColor);
        scope(exit){
            graphics.restoreColor;
        }

        //TODO vertical
        const bounds = barContainer.boundsRect;
        const leftTopX = bounds.x + padding.left;
        const leftTopY = bounds.y + padding.top;
        
        const drawFullW = bounds.width - padding.right;
        const drawW = value * drawFullW / maxValue;
        const drawH = bounds.height - padding.bottom;

        graphics.rect(leftTopX, leftTopY, drawFullW, drawH);
        graphics.fillRect(leftTopX, leftTopY, drawW, drawH);
    }

    override protected void setProgressData(double oldV, double newV)
    {
       super.setProgressData(oldV, newV);
    }

}
