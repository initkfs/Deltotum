module api.dm.gui.controls.charts.lines.linear_chart;

import api.dm.gui.controls.charts.xy_chart : XYChart;
import api.dm.gui.controls.control : Control;
import api.math.geom2.vec2 : Vec2d;
import api.math.insets : Insets;
import api.dm.kit.graphics.colors.rgba : RGBA;
import MaterialPalette = api.dm.kit.graphics.colors.palettes.material_palette;
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
class LinearChart : XYChart
{
    protected
    {
        double[] xValues;
        double[] yValues;
    }

    RGBA colorChartLine;

    bool isThickLine;

    this(double chartAreaWidth = 100, double chartAreaHeight = 100)
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

    void data(double[] newX, double[] newY)
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
        graphics.setClip(chartBounds);
        scope (exit)
        {
            graphics.removeClip;
        }

        graphics.setColor(colorChartLine);
        scope (exit)
        {
            graphics.restoreColor;
        }

        Vec2d prev;
        foreach (i, valueX; xValues)
        {
            const valueY = yValues[i];

            const pos = toChartAreaPos(valueX, valueY);

            if (i > 0)
            {
                graphics.line(prev.x, prev.y, pos.x, pos.y);
                if (isThickLine)
                {
                    graphics.line(prev.x, prev.y - 1, pos.x, pos.y - 1);
                    graphics.line(prev.x, prev.y + 1, pos.x, pos.y + 1);
                }

            }

            prev = pos;
        }

        drawAxis;
        trackPointer;
    }
}
