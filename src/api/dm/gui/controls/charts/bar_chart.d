module api.dm.gui.controls.charts.bar_chart;

import api.dm.gui.controls.charts.xy_chart : XYChart;
import api.dm.gui.containers.container : Container;
import api.dm.gui.controls.texts.text : Text;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.controls.scales.render_hscale : RenderHScale;
import api.dm.gui.controls.scales.render_vscale : RenderVScale;
import api.dm.gui.containers.hbox : HBox;
import api.dm.gui.containers.vbox : VBox;

import api.math.vector2 : Vector2;
import Math = api.math;

struct BarData
{
    dstring label;
    double valueY = 0;
    RGBA color = RGBA.red;
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

    protected
    {
        size_t datasetItems;
    }

    this(double chartAreaWidth = 100, double chartAreaHeight = 100)
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

        auto dataBlockW = (chartArea.width) / datasetItems;
        double nextX = startPos.x;
        
        foreach (BarSet dataset; datasets)
        {
            foreach (BarData data; dataset.values)
            {
                auto dataBlockH = rangeYToHeight(Math.abs(data.valueY));
                auto posY = startPos.y - dataBlockH;
                if(data.valueY < 0){
                    
                }
                graphics.fillRect(Vector2(nextX,posY), dataBlockW, dataBlockH, data.color);
                nextX+= dataBlockW;
            }
            //nextX+= datasetSpacing;
        }

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
        minX = newMinY;
        maxX = newMaxY;

        this.datasets = datasets;

        if (yScale1)
        {
            yScale1.minValue = newMinY;
            yScale1.maxValue = newMaxY;
            yScale1.valueStep = rangeY / 11.0;
            yScale1.majorTickStep = 5;
            yScale1.recreate;
        }
    }
}
