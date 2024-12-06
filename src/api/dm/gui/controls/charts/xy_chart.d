module api.dm.gui.controls.charts.xy_chart;

import api.dm.gui.containers.container : Container;
import api.dm.gui.controls.texts.text : Text;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.controls.meters.scales.dynamics.hscale_dynamic : HScaleDynamic;
import api.dm.gui.controls.meters.scales.dynamics.vscale_dynamic : VScaleDynamic;
import api.dm.gui.containers.hbox : HBox;
import api.dm.gui.containers.vbox : VBox;

import api.dm.com.inputs.com_keyboard : ComKeyName;

import api.math.geom2.vec2 : Vec2d;
import Math = api.math;

/**
 * Authors: initkfs
 */
class XYChart : Container
{
    double minX = 0;
    double maxX = 1;
    double minY = 0;
    double maxY = 1;

    bool isAutoScale = true;

    HScaleDynamic xScale1;
    VScaleDynamic yScale1;

    double chartAreaWidth = 0;
    double chartAreaHeight = 0;

    Container chartArea;

    double scaleAutoSize = 20;

    bool isScalable = true;
    bool isDraggableChart = true;

    double scaleX = 1;
    double scaleY = 1;

    double offsetX = 0;
    double offsetY = 0;

    bool isShowXScale = true;
    bool isShowYScale = true;

    RGBA xAxisColor;
    RGBA yAxisColor;
    RGBA gridColor = RGBA(35, 35, 35);

    Text trackPointerInfo;

    bool isTrackPointer = true;
    RGBA trackPointerColor;
    //RCTRL
    ComKeyName trackPointerAltKey = ComKeyName.LCTRL;

    size_t labelNumberPrecision = 2;
    size_t prefLabelGlyphWidth = 4;

    protected
    {
        bool isStartTrackPointer;
    }

    this(double chartAreaWidth = 200, double chartAreaHeight = 200)
    {
        assert(chartAreaWidth > 0);
        assert(chartAreaHeight > 0);
        this.chartAreaWidth = chartAreaWidth;
        this.chartAreaHeight = chartAreaHeight;

        padding = 5;

        import api.dm.kit.sprites.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout(0);
        layout.isAutoResize = true;
    }

    override void create()
    {
        super.create;

        enableInsets;

        if (xAxisColor == RGBA.init)
        {
            xAxisColor = theme.colorWarning;
        }

        if (yAxisColor == RGBA.init)
        {
            yAxisColor = theme.colorWarning;
        }

        auto chartContentContainer = new HBox(0);
        chartContentContainer.isResizeChildren = false;
        chartContentContainer.layout.isResizeChildren = false;
        addCreate(chartContentContainer);

        yScale1 = new VScaleDynamic(scaleAutoSize, chartAreaHeight);
        yScale1.isInvertY = true;
        yScale1.isDrawFirstTick = false;
        yScale1.labelNumberPrecision = labelNumberPrecision;
        yScale1.prefLabelGlyphWidth = prefLabelGlyphWidth;
        chartContentContainer.addCreate(yScale1);

        if (!isShowYScale)
        {
            yScale1.isVisible = false;
        }

        chartArea = new Container;
        chartArea.width = chartAreaWidth;
        chartArea.height = chartAreaHeight;
        chartContentContainer.addCreate(chartArea);

        xScale1 = new HScaleDynamic(chartAreaWidth, scaleAutoSize);
        xScale1.marginLeft = scaleAutoSize;
        xScale1.isDrawFirstTick = false;
        xScale1.isShowFirstLabelText = false;
        xScale1.labelNumberPrecision = labelNumberPrecision;
        xScale1.prefLabelGlyphWidth = prefLabelGlyphWidth;
        addCreate(xScale1);

        if (!isShowXScale)
        {
            xScale1.isVisible = false;
        }

        //auto xScaleRangeLimit = 50;
        //auto xScaleRangeMinLimit = 0.5;

        if (isScalable)
        {
            onPointerWheel ~= (ref e) {
                double scaleFactor = 1.5;
                //up e.y = 1, down e.y = -1
                if (e.y < 0)
                {
                    scaleFactor = 1.0 / scaleFactor;
                }
                auto newMaxXValue = xScale1.maxValue / scaleFactor;
                if (newMaxXValue > xScale1.minValue)
                {
                    auto newXRange = Math.abs(newMaxXValue - xScale1.minValue);
                    // if (newXRange >= xScaleRangeMinLimit && newXRange <= xScaleRangeLimit)
                    // {
                       
                    // }
                    // else
                    // {
                    //     // xScale1.maxValue = maxX;
                    //     // xScale1.recreate;
                    //     // scaleX = 1;
                    // }
                    xScale1.maxValue = newMaxXValue;
                    xScale1.recreate;
                    scaleX = rangeX / xScale1.range;
                }

                auto newMaxYValue = yScale1.maxValue / scaleFactor;
                if (newMaxYValue > yScale1.minValue)
                {
                    // auto newYRange = Math.abs(newMaxYValue - yScale1.minValue);
                    // if (newYRange >= xScaleRangeMinLimit && newYRange <= xScaleRangeLimit)
                    // {
                        
                    // }
                    // else
                    // {
                    //     // yScale1.maxValue = maxY;
                    //     // yScale1.recreate;
                    //     // scaleY = 1;
                    // }
                    yScale1.maxValue = newMaxYValue;
                    yScale1.recreate;
                    scaleY = rangeY / yScale1.range;
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
                auto speedXFactor = scaleX == 1 ? speedFactor : speedFactor * scaleX;
                auto speedYFactor = scaleY == 1 ? speedFactor : speedFactor * scaleY;
                auto speedX = rangeX / speedXFactor;
                auto speedY = rangeY / speedYFactor;

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

        if (isTrackPointer)
        {

            if (trackPointerColor == RGBA.init)
            {
                trackPointerColor = theme.colorSuccess;
            }

            trackPointerInfo = new Text;
            trackPointerInfo.setSmallSize;
            trackPointerInfo.isVisible = false;
            addCreate(trackPointerInfo);

            chartArea.onPointerEnter ~= (ref e) { isStartTrackPointer = true; };

            chartArea.onPointerExit ~= (ref e) { isStartTrackPointer = false; };
        }
    }

    double rangeX() => maxX - minX;
    double rangeY() => maxY - minY;

    protected double rangeXToWidth(double x, bool isUseOffsets = true, bool isUseScale = true)
    {
        assert(chartArea);

        if (x < 0)
        {
            x = -x;
        }

        if (minX < 0 && maxX > 0)
        {
            x += (0 - minX);
        }
    
        if (isUseOffsets)
        {
            x = offsetX + x;
        }

        if(isUseScale){
            x *= scaleX;
        }

        auto wX = (chartArea.width / rangeX) * x;
        //Clipping here can change the shape of the curve
        return wX;
    }

    protected double rangeYToHeight(double y, bool isUseOffsets = true, bool isUseScale = true)
    {
        assert(chartArea);
        if (y < 0)
        {
            y = -y;
        }

        if (minY < 0 && maxY > 0)
        {
            y += (0 - minY);
        }

        if (isUseOffsets)
        {
            y = offsetY + y;
        }

        if(isUseScale){
            y *= scaleY;
        }

        auto hY = (chartArea.height / rangeY) * y;
        return hY;
    }

    double widthToX(double w)
    {
        if (w < 0 || w > chartAreaWidth)
        {
            //TODO error?
            return 0;
        }
        return xScale1.minValue + (w * xScale1.range / chartAreaWidth);
    }

    double heightToY(double h)
    {
        if (h < 0 || h > chartAreaHeight)
        {
            //TODO error?
            return 0;
        }
        return yScale1.maxValue - (h * yScale1.range / chartAreaHeight);
    }

    protected Vec2d toChartAreaPos(double posX, double posY, bool isUseOffsets = true, bool isUseScale = true)
    {
        assert(chartArea);

        //TODO may be negative if the chart goes beyond the boundaries
        auto wX = rangeXToWidth(posX, isUseOffsets, isUseScale);
        auto hY = rangeYToHeight(posY, isUseOffsets, isUseScale);

        double newX = 0;
        double newY = 0;

        //TODO reference point
        if (posX >= 0)
        {
            newX = chartArea.x + wX;
        }
        else
        {
            //TODO or minValue from scales?
            if (minX < 0)
            {
                auto xZeroOffset = 0 - xScale1.minValue;
                auto wZeroOffset = rangeXToWidth(xZeroOffset);
                //TODO check negative scales
                if(wX < 0){
                    wX = -wX;
                }
                newX = chartArea.x + wZeroOffset - wX;
            }
        }

        if (posY >= 0)
        {
            newY = chartArea.boundsRect.bottom - hY;
        }
        else
        {
            if (minY < 0)
            {
                auto yZeroOffset = 0 - yScale1.minValue;
                auto hZeroOffset = rangeYToHeight(yZeroOffset);
                if(hY < 0){
                    hY = -hY;
                }
                newY = chartArea.boundsRect.bottom - hZeroOffset + hY;
            }
        }

        return Vec2d(newX, newY);
    }

    void drawAxis()
    {
        auto zeroPos = toChartAreaPos(0, 0);

        if (yScale1.minValue < 0 && yScale1.maxValue > 0)
        {
            graphics.line(chartArea.x, zeroPos.y, chartArea.boundsRect.right, zeroPos.y, xAxisColor);
        }

        if (xScale1.minValue < 0 && xScale1.maxValue > 0)
        {
            graphics.line(zeroPos.x, chartArea.y, zeroPos.x, chartArea.boundsRect.bottom, yAxisColor);
        }
    }

    void drawGrid()
    {

        auto xTicks = xScale1.tickCount;
        auto yTicks = yScale1.tickCount;

        auto tickXDiff = chartAreaWidth / (xTicks - 1);
        double startX = 0;
        //TODO major;
        double tickW = xScale1.tickMinorWidth / 2.0;
        foreach (x; 0 .. xTicks)
        {
            auto tickPos = chartArea.x + startX - tickW;
            graphics.line(tickPos, chartArea.y, tickPos, chartArea.boundsRect.bottom, gridColor);
            startX += tickXDiff;
        }

        auto tickYDiff = chartAreaHeight / (yTicks - 1);
        double startY = 0;
        double tickH = yScale1.tickMinorHeight / 2.0;
        foreach (y; 0 .. yTicks)
        {
            double tickPos = chartArea.y + startY - tickH;
            graphics.line(chartArea.x, tickPos, chartArea.boundsRect.right, tickPos, gridColor);
            startY += tickYDiff;
        }

    }

    void trackPointer()
    {
        if (!isStartTrackPointer || !input.isPressedKey(trackPointerAltKey))
        {
            if(trackPointerInfo.isVisible){
                trackPointerInfo.isVisible = false;
            }
            return;
        }

        if(!trackPointerInfo.isVisible){
            trackPointerInfo.isVisible = true;
        }

        Vec2d pointerPos = input.pointerPos;
        auto dx = pointerPos.x - chartArea.x;
        auto dy = pointerPos.y - chartArea.y;
        if (dx < 0 || dy < 0)
        {
            return;
        }

        graphics.line(chartArea.x + dx, chartArea.y, chartArea.x + dx, chartArea.boundsRect.bottom, trackPointerColor);
        graphics.line(chartArea.x, chartArea.y + dy, chartArea.boundsRect.right, chartArea.y + dy, trackPointerColor);

        auto dxInfo = widthToX(dx);
        auto dyInfo = heightToY(dy);

        import std.format : format;

        trackPointerInfo.text = format("x:%.2f y:%.2f", dxInfo, dyInfo);
    }
}
