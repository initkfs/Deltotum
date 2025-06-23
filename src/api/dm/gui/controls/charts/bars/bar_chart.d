module api.dm.gui.controls.charts.bars.bar_chart;

import api.dm.gui.controls.charts.xy_chart : XYChart;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.texts.text : Text;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.controls.meters.scales.dynamics.hscale_dynamic : HScaleDynamic;
import api.dm.gui.controls.meters.scales.dynamics.vscale_dynamic : VScaleDynamic;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.gui.controls.containers.vbox : VBox;

import api.math.geom2.vec2 : Vec2d;
import Math = api.math;

struct BarData
{
    dstring label;
    double valueY = 0;
    RGBA color = RGBA.darkorchid;
}

struct BarSet
{
    dstring name;
    BarData[] values;
}

/**
 * Authors: initkfs
 */
class BarChart : XYChart
{
    BarSet[] datasets;

    //TODO assert(sp < chart.w)
    size_t datasetSpacing = 5;

    protected
    {
        size_t datasetItems;
    }

    this(double chartAreaWidth = 0, double chartAreaHeight = 0)
    {
        super(chartAreaWidth, chartAreaHeight);

        isShowXScale = false;
    }

    override void create()
    {
        super.create;
    }

    override void drawContent()
    {
        super.drawContent;

        if (!isCreated || datasets.length == 0 || datasetItems == 0)
        {
            return;
        }

        //TODO in bounds, min\max
        auto startPos = toChartAreaPos(0, 0);

        auto dataBlockW = (chartArea.width - datasetSpacing * datasets.length) / datasetItems;
        double nextX = startPos.x + datasetSpacing;

        drawGrid;

        //TODO from xScale
        if(!isShowXScale){
             auto color = xScale1 ? xScale1.axisColor : xAxisColor;
             graphic.line(chartArea.x, chartArea.boundsRect.bottom, chartArea.boundsRect.right, chartArea.boundsRect.bottom , color);
        }

        graphic.clip(chartArea.boundsRect);
        scope (exit)
        {
            graphic.clearClip;
        }
        
        foreach (BarSet dataset; datasets)
        {
            foreach (BarData data; dataset.values)
            {
                auto dataBlockH = Math.round(rangeYToHeight(Math.abs(data.valueY), false));
                auto posY = (data.valueY > 0) ? startPos.y - dataBlockH : startPos.y;
                graphic.fillRect(Vec2d(nextX,posY), dataBlockW, dataBlockH, data.color);
                nextX+= dataBlockW;
            }
            nextX+= datasetSpacing;
        }

        drawAxis;
    }

    void data(BarSet[] datasets)
    {
        maxX = 0;
        minY = 0;
        minX = 0;
        maxX = 0;
        datasetItems = 0;

        double newMaxY = 0;
        double newMinY = 0;

        foreach (dataset; datasets)
        {
            foreach (BarData newData; dataset.values)
            {
                if (newData.valueY > newMaxY)
                {
                    newMaxY = newData.valueY;
                }

                if (newData.valueY < newMinY)
                {
                    newMinY = newData.valueY;
                }

                datasetItems++;
            }
        }

        maxY = newMaxY;
        minY = newMinY;
        minX = 0;
        maxX = Math.abs(newMaxY);

        this.datasets = datasets;

        if (yScale1)
        {
            yScale1.minValue = newMinY;
            yScale1.maxValue = newMaxY;
            yScale1.valueStep = rangeY / 10.0;
            yScale1.majorTickStep = 5;
            yScale1.recreate;
        }
    }
}
