module api.dm.gui.controls.charts.xy_chart;

import api.dm.gui.containers.container : Container;
import api.dm.gui.controls.texts.text : Text;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.controls.scales.render_hscale : RenderHScale;
import api.dm.gui.controls.scales.render_vscale : RenderVScale;
import api.dm.gui.containers.hbox : HBox;
import api.dm.gui.containers.vbox : VBox;

import api.math.vector2 : Vector2;
import Math = api.math;

/**
 * Authors: initkfs
 */
class XYChart : Container
{
    double minX = 0;
    double maxX = 0;
    double minY = 0;
    double maxY = 0;

    RenderHScale xScale1;
    RenderVScale yScale1;

    double chartAreaWidth = 0;
    double chartAreaHeight = 0;

    Container chartArea;

    double scaleAutoSize = 40;

    bool isScalable = true;
    bool isDraggableChart = true;

    double scaleX = 1;
    double scaleY = 1;

    double offsetX = 0;
    double offsetY = 0;

    bool isShowXScale = true;
    bool isShowYScale = true;

    this(double chartAreaWidth = 200, double chartAreaHeight = 200)
    {
        assert(chartAreaWidth > 0);
        assert(chartAreaHeight > 0);
        this.chartAreaWidth = chartAreaWidth;
        this.chartAreaHeight = chartAreaHeight;

        isBorder = true;

        padding = 5;

        import api.dm.kit.sprites.layouts.vlayout : VLayout;

        layout = new VLayout(5);
        layout.isAutoResize = true;

        isDrawBounds = true;
    }

    override void create()
    {
        super.create;

        enableInsets;

        auto chartContentContainer = new HBox(0);
        chartContentContainer.isResizeChildren = false;
        chartContentContainer.layout.isResizeChildren = false;
        addCreate(chartContentContainer);

        yScale1 = new RenderVScale(scaleAutoSize, chartAreaHeight);
        yScale1.isInvert = true;
        chartContentContainer.addCreate(yScale1);

        yScale1.isDrawBounds = true;

        if(!isShowYScale){
            yScale1.isVisible = false;
        }

        chartArea = new Container;
        chartArea.width = chartAreaWidth;
        chartArea.height = chartAreaHeight;
        chartArea.isDrawBounds = true;
        chartContentContainer.addCreate(chartArea);

        xScale1 = new RenderHScale(chartAreaWidth, scaleAutoSize);
        xScale1.marginLeft = scaleAutoSize;
        addCreate(xScale1);
        xScale1.isDrawBounds = true;

        if(!isShowXScale){
            xScale1.isVisible = false;
        }

        auto xScaleRangeLimit = 50;
        auto xScaleRangeMinLimit = 0.5;

        size_t scaleAccum;
        size_t scaleAccumFull = 3;

        if (isScalable)
        {
            onPointerWheel ~= (ref e) {
                scaleAccum++;
                if (scaleAccum <= scaleAccumFull)
                {
                    return;
                }
                scaleAccum = 0;
                double scaleFactor = 2;
                //up e.y = 1, down e.y = -1
                if (e.y < 0)
                {
                    scaleFactor = 1.0 / scaleFactor;
                }
                auto newMaxXValue = xScale1.maxValue / scaleFactor;
                auto newXRange = Math.abs(newMaxXValue - xScale1.minValue);
                if (newXRange >= xScaleRangeMinLimit && newXRange <= xScaleRangeLimit)
                {
                    xScale1.maxValue = newMaxXValue;
                    xScale1.recreate;
                    scaleX = maxX / xScale1.maxValue;
                }
                else
                {
                    // xScale1.maxValue = maxX;
                    // xScale1.recreate;
                    // scaleX = 1;
                }

                auto newMaxYValue = yScale1.maxValue / scaleFactor;
                auto newYRange = Math.abs(newMaxYValue - yScale1.minValue);
                if (newYRange >= xScaleRangeMinLimit && newYRange <= xScaleRangeLimit)
                {
                    yScale1.maxValue = newYRange;
                    yScale1.recreate;
                    scaleY = maxY / yScale1.maxValue;
                }
                else
                {
                    // yScale1.maxValue = maxY;
                    // yScale1.recreate;
                    // scaleY = 1;
                }
            };
        }

        if (isDraggableChart)
        {
            chartArea.isDraggable = true;

            chartArea.onDragXY = (dragX, dragY) {

                auto dx = dragX - chartArea.x;
                auto dy = dragY - chartArea.y;

                auto tresholdX = 5;
                auto tresholdY = tresholdX;

                //move to right x > 0 
                double speedFactor = 100;
                auto speedX = (rangeX > 0) ? rangeX / speedFactor : 1 / 10.0;
                auto speedY = (rangeY > 0) ? rangeY / speedFactor : 1 / 10.0;
                
                auto stepX = Math.sign(dx) * speedX;
                auto stepY = Math.sign(dy) * speedY;

                if (Math.abs(dx) > tresholdX)
                {
                    offsetX += stepX;
                    xScale1.minValue -= stepX;
                    xScale1.maxValue -= stepX;
                    xScale1.recreate;
                }

                if (Math.abs(dy) > tresholdY)
                {
                    offsetY -= stepY;
                    yScale1.minValue += stepY;
                    yScale1.maxValue += stepY;
                    yScale1.recreate;
                }

                return false;
            };
        }
    }

    double rangeX() => maxX - minX;
    double rangeY() => maxY - minY;

    protected double rangeXToWidth(double x)
    {
        assert(chartArea);
        auto wX = (chartArea.width / rangeX) * (offsetX + x * scaleX);
        //Clipping here can change the shape of the curve
        return wX;
    }

    protected double rangeYToHeight(double y)
    {
        assert(chartArea);
        auto hY = (chartArea.height / rangeY) * (offsetY + y * scaleY);
        return hY;
    }

    protected Vector2 toChartAreaPos(double posX, double posY)
    {
        assert(chartArea);

        auto wX = rangeXToWidth(posX);
        auto hY = rangeYToHeight(posY);

        const newX = chartArea.x + wX;
        const newY = chartArea.bounds.bottom - hY;

        return Vector2(newX, newY);
    }
}
