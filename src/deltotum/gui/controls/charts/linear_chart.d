module deltotum.gui.controls.charts.linear_chart;

import deltotum.gui.controls.control : Control;
import deltotum.math.vector2d : Vector2d;
import deltotum.math.geom.insets : Insets;
import deltotum.kit.graphics.colors.rgba : RGBA;
import deltotum.kit.graphics.colors.palettes.material_design_palette : MaterialDesignPalette;

import Math = deltotum.math;
import std.math.operations : isClose;

/**
 * Authors: initkfs
 */
class LinearChart : Control
{
    protected
    {
        double[] xValues;
        double[] yValues;

        double minX = 0;
        double maxX = 0;
        double minY = 0;
        double maxY = 0;

        double rangeX = 0;
        double rangeY = 0;

        Vector2d _referencePoint;
    }

    this(double width = 100, double height = 100)
    {
        this.width = width;
        this.height = height;

        isBorder = true;
        padding = Insets(10);
    }

    override void initialize()
    {
        super.initialize;
        _referencePoint = Vector2d(0, height);
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

        auto valueFilter = delegate(double[] arr) { return arr.filter!isFinite; };

        minX = valueFilter(newX).minElement;
        maxX = valueFilter(newX).maxElement;
        const rangeX = maxX - minX;

        if (isClose(rangeX, 0.0, 0.0, 1e-9))
        {
            if (minX < 0)
            {
                maxX = 0;
            }
            else
            {
                minX = 0;
            }
        }

        minY = valueFilter(newY).minElement;
        maxY = valueFilter(newY).maxElement;
        const rangeY = maxY - minY;

        if (isClose(rangeY, 0.0, 0.0, 1e-9))
        {
            if (minY < 0)
            {
                maxY = 0;
            }
            else
            {
                minY = 0;
            }
        }

        xValues = newX;
        yValues = newY;

        this.rangeX = maxX - minX;
        this.rangeY = maxY - minY;

        if (minX < 0)
        {
            const xOffset = rangeXToWidth(minX);
            _referencePoint.x -= xOffset;
        }

        if (minY < 0)
        {
            const yOffset = rangeYToHeight(minY);
            _referencePoint.y += yOffset;
        }
    }

    protected double rangeXToWidth(double x)
    {
        auto wX = ((width - padding.width) / rangeX) * x;
        return wX;
    }

    protected double rangeYToHeight(double y)
    {
        auto hY = ((height - padding.height) / rangeY) * y;
        return hY;
    }

    protected Vector2d toSpritePos(double posX, double posY)
    {
        import Math = deltotum.math;

        auto wX = rangeXToWidth(posX);
        auto hY = rangeYToHeight(posY);

        const newX = x + _referencePoint.x + wX;
        const newY = y + _referencePoint.y + hY;

        return Vector2d(newX, newY);
    }

    override bool draw()
    {
        super.draw;
        
        const b = bounds;
        import deltotum.math.shapes.rect2d : Rect2d;

        drawAxis;

        const boundsWithPadding = paddingBounds;
        foreach (i, valueX; xValues)
        {
            const valueY = yValues[i];
            const pos = toSpritePos(valueX, valueY);

            const drawX = pos.x;
            const drawY = pos.y;

            // if (!boundsWithPadding.contains(drawX, drawY))
            // {
            //     continue;
            // }

            graphics.drawPoint(drawX, drawY);
        }
        return true;
    }

    protected void drawAxis()
    {
        const minXPos = _referencePoint.x;
        const minYPos = height - _referencePoint.y;
        
        const maxXPos = width - padding.right;
        const maxYPos = padding.top;

        graphics.drawLine(x + minXPos, y + minYPos, x + maxXPos, y + minYPos, RGBA.web(
                MaterialDesignPalette.green300));
        graphics.drawLine(x + minXPos, y + minYPos, x + minXPos, y + maxYPos, RGBA.web(
                MaterialDesignPalette.yellow300));

    }

    void referencePoint(double x, double y)
    {
        _referencePoint = Vector2d(x, y);
    }

    Vector2d referencePoint()
    {
        return _referencePoint;
    }

}
