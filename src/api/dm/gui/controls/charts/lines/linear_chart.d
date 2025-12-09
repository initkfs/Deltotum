module api.dm.gui.controls.charts.lines.linear_chart;

import api.dm.gui.controls.charts.xy_chart : XYChart;
import api.dm.gui.controls.control : Control;
import api.math.geom2.vec2 : Vec2f;
import api.math.pos2.insets : Insets;
import api.dm.kit.graphics.colors.rgba : RGBA;
import MaterialPalette = api.dm.kit.graphics.colors.palettes.material_palette;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.gui.controls.containers.vbox : VBox;
import api.dm.gui.controls.meters.scales.dynamics.hscale_dynamic : HScaleDynamic;
import api.dm.gui.controls.meters.scales.dynamics.vscale_dynamic : VScaleDynamic;

import Math = api.dm.math;
import std.math.operations : isClose;
import api.math.numericals.interp;

/**
 * Authors: initkfs
 */
class LinearChart : XYChart
{
    protected
    {
        float[] xValues;
        float[] yValues;
    }

    RGBA colorChartLine;

    bool isThickLine;

    this(float chartAreaWidth = 100, float chartAreaHeight = 100)
    {
        super(chartAreaWidth, chartAreaHeight);
    }

    override void create()
    {
        super.create;

        if (colorChartLine == RGBA.init)
        {
            colorChartLine = theme.colorAccent;
        }
    }

    void data(float[] newX, float[] newY)
    {
        if (newX.length != newY.length)
        {
            import std.format : format;

            throw new Exception(format("Size mismatch between x-abscissa (%s) and y-ordinate (%s)", newX.length, newY
                    .length));
        }

        if (isAutoScale)
        {
            import std.algorithm.iteration : filter;
            import std.algorithm.searching : minElement, maxElement;
            import std.math.traits : isFinite;

            auto valueFilter = (float[] arr) { return arr.filter!isFinite; };

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

            if (xScale1)
            {
                xScale1.minValue = minX;
                xScale1.maxValue = maxX;
                xScale1.valueStep = rangeX / 10.0;
                xScale1.recreate;
            }

            if (yScale1)
            {
                yScale1.minValue = minY;
                yScale1.maxValue = maxY;
                yScale1.valueStep = rangeY / 10.0;
                yScale1.recreate;
            }
        }

        xValues = newX;
        yValues = newY;
    }

    override void drawContent()
    {
        super.drawContent;

        auto chartBounds = chartArea.boundsRect;

        drawGrid;

        //TODO best clipping
        graphic.clip(chartBounds);
        scope (exit)
        {
            graphic.clearClip;
        }

        graphic.changeColor(colorChartLine);
        scope (exit)
        {
            graphic.restoreColor;
        }

        Vec2f prev;
        foreach (i, valueX; xValues)
        {
            const valueY = yValues[i];

            const pos = toChartAreaPos(valueX, valueY);

            if (i > 0)
            {
                graphic.line(prev.x, prev.y, pos.x, pos.y);
                if (isThickLine)
                {
                    graphic.line(prev.x, prev.y - 1, pos.x, pos.y - 1);
                    graphic.line(prev.x, prev.y + 1, pos.x, pos.y + 1);
                }

            }

            prev = pos;
        }

        drawAxis;
        trackPointer;
    }
}
