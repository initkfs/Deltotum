module api.dm.gui.controls.charts.linear_chart;

import api.dm.gui.controls.control : Control;
import api.math.vector2 : Vector2;
import api.math.insets : Insets;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.colors.palettes.material_palette : MaterialPalette;
import api.dm.gui.containers.container : Container;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.containers.hbox : HBox;
import api.dm.gui.containers.vbox : VBox;
import api.dm.gui.controls.scales.render_hscale : RenderHScale;
import api.dm.gui.controls.scales.render_vscale : RenderVScale;

import Math = api.dm.math;
import std.math.operations : isClose;
import api.math.numericals.interp;

/**
 * Authors: initkfs
 */
class LinearChart : Container
{
    protected
    {
        double[] xValues;
        double[] yValues;

        double minX = 0;
        double maxX = 0;
        double minY = 0;
        double maxY = 0;

        RenderHScale xScale1;
        RenderVScale yScale1;

        Container chartArea;

        double chartAreaWidth;
        double chartAreaHeight;

        double scaleX = 1;
        double scaleY = 1;

        double offsetX = 0;
        double offsetY = 0;
    }

    RGBA colorChartLine = RGBA.green;
    RGBA colorXAxis = RGBA.lightgray;
    RGBA colorYAxis = RGBA.lightgray;

    this(double chartAreaWidth = 100, double chartAreaHeight = 100)
    {
        assert(chartAreaWidth > 0);
        assert(chartAreaHeight > 0);
        this.chartAreaWidth = chartAreaWidth;
        this.chartAreaHeight = chartAreaHeight;

        isBorder = true;
        padding = Insets(5);

        import api.dm.kit.sprites.layouts.vlayout : VLayout;

        layout = new VLayout(5);
        layout.isAutoResize = true;
    }

    override void initialize()
    {
        super.initialize;
    }

    override void create()
    {
        super.create;

        enableInsets;

        enum scaleAutoSize = 40;

        auto chartContentContainer = new HBox(0);
        chartContentContainer.isResizeChildren = false;
        chartContentContainer.layout.isResizeChildren = false;
        addCreate(chartContentContainer);
        yScale1 = new RenderVScale(scaleAutoSize, chartAreaHeight);
        yScale1.isInvert = true;
        chartContentContainer.addCreate(yScale1);
        yScale1.isDrawBounds = true;

        chartArea = new Container;
        chartArea.width = chartAreaWidth;
        chartArea.height = chartAreaHeight;
        chartArea.isDrawBounds = true;
        chartContentContainer.addCreate(chartArea);

        xScale1 = new RenderHScale(chartAreaWidth, scaleAutoSize);
        xScale1.marginLeft = scaleAutoSize;
        addCreate(xScale1);
        xScale1.isDrawBounds = true;

        auto xScaleRangeLimit = 50;
        auto xScaleRangeMinLimit = 0.5;

        size_t scaleAccum;
        size_t scaleAccumFull = 3;

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
                //xScale1.valueStep = xScale1.valueStep / scaleFactor;
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
                //yScale1.valueStep = yScale1.valueStep * scaleFactor;
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

        isDraggable = true;

        onDragXY = (x, y) {

            auto dx = x - this.x;
            auto dy = y - this.y;

            auto tresholdX = 5;
            auto tresholdY = tresholdX;

            //move to right x > 0 
            auto speed = (maxX - minX) / 100;
            auto stepX = Math.sign(dx) * speed;
            auto stepY = Math.sign(dy) * speed;

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

        //onStopDrag = () { offsetX = 0; offsetY = 0; };
    }

    void data(double[] newX, double[] newY)
    {
        if (newX.length != newY.length)
        {
            import std.format : format;

            throw new Exception(format("Size mismatch between x-abscissa (%s) and y-ordinate (%s)", newX.length, newY
                    .length));
        }

        import std.algorithm.iteration : filter;
        import std.algorithm.searching : minElement, maxElement;
        import std.math.traits : isFinite;

        auto valueFilter = (double[] arr) { return arr.filter!isFinite; };

        minX = valueFilter(newX).minElement;
        maxX = valueFilter(newX).maxElement;

        if (minX > 0 && maxX > 0)
        {
            minX = 0;
        }

        minY = valueFilter(newY).minElement;
        maxY = valueFilter(newY).maxElement;

        if (minY > 0 && maxY > 0)
        {
            minY = 0;
        }

        xValues = newX;
        yValues = newY;

        if (xScale1)
        {
            xScale1.minValue = minX;
            xScale1.maxValue = maxX;
            //xScale1.valueStep = rangeX / 11.0;
            xScale1.valueStep = 1;
            xScale1.majorTickStep = 1;
            xScale1.recreate;
        }

        if (yScale1)
        {
            yScale1.minValue = minY;
            yScale1.maxValue = maxY;
            //yScale1.valueStep = rangeY / 11.0;
            yScale1.valueStep = 1;
            yScale1.majorTickStep = 1;
            yScale1.recreate;
        }
    }

    double rangeX()
    {
        return maxX - minX;
    }

    double rangeY()
    {
        return maxY - minY;
    }

    override void drawContent()
    {
        super.drawContent;

        auto chartBounds = chartArea.bounds;

        //TODO best clipping
        graphics.setClip(chartBounds);
        scope (exit)
        {
            graphics.removeClip;
        }

        graphics.setColor(colorChartLine);
        scope(exit){
            graphics.restoreColor;
        }

        Vector2 prev;
        foreach (i, valueX; xValues)
        {
            const valueY = yValues[i];

            const pos = toCharAreaPos(valueX, valueY);

            if (i > 0)
            {
                graphics.line(prev.x, prev.y, pos.x, pos.y);
                graphics.line(prev.x, prev.y - 1, pos.x, pos.y - 1);
            }

            prev = pos;
        }

    }

    protected double rangeXToWidth(double x)
    {
        auto wX = (chartArea.width / rangeX) * (offsetX + x * scaleX - minX);
        return wX;
    }

    protected double rangeYToHeight(double y)
    {
        auto hY = (chartArea.height / rangeY) * (offsetY + y * scaleY - minY);
        return hY;
    }

    protected Vector2 toCharAreaPos(double posX, double posY)
    {
        import Math = api.dm.math;

        auto wX = rangeXToWidth(posX);
        auto hY = rangeYToHeight(posY);

        const newX = chartArea.x + wX;
        const newY = chartArea.bounds.bottom - hY;

        return Vector2(newX, newY);
    }
}
