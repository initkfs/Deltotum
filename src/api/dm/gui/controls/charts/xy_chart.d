module api.dm.gui.controls.charts.xy_chart;

import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.meters.scales.dynamics.hscale_dynamic : HScaleDynamic;
import api.dm.gui.controls.meters.scales.dynamics.vscale_dynamic : VScaleDynamic;
import api.dm.gui.controls.texts.text : Text;
import api.dm.kit.graphics.colors.rgba : RGBA;

import api.dm.com.inputs.com_keyboard : ComKeyName;

import api.math.geom2.vec2 : Vec2d;
import Math = api.math;

/**
 * Authors: initkfs
 */
class XYChart : Container
{
    float minX = 0;
    float maxX = 1;
    float minY = 0;
    float maxY = 1;

    bool isAutoScale = true;

    HScaleDynamic xScale1;
    bool isCreateXScale1 = true;
    HScaleDynamic delegate(HScaleDynamic) onNewXScale1;
    void delegate(HScaleDynamic) onConfiguredXScale1;
    void delegate(HScaleDynamic) onCreatedXScale1;

    VScaleDynamic yScale1;
    bool isCreateYScale1 = true;
    VScaleDynamic delegate(VScaleDynamic) onNewYScale1;
    void delegate(VScaleDynamic) onConfiguredYScale1;
    void delegate(VScaleDynamic) onCreatedYScale1;

    float chartAreaWidth = 0;
    float chartAreaHeight = 0;

    Container chartArea;
    bool isCreateChartArea = true;
    Container delegate(Container) onNewChartArea;
    void delegate(Container) onConfiguredChartArea;
    void delegate(Container) onCreatedChartArea;

    bool isScalable = true;
    bool isDraggableChart = true;

    float scaleX = 1;
    float scaleY = 1;

    float offsetX = 0;
    float offsetY = 0;

    bool isShowXScale = true;
    bool isShowYScale = true;

    RGBA xAxisColor;
    RGBA yAxisColor;
    RGBA gridColor = RGBA(35, 35, 35);

    Text trackPointerInfo;
    bool isCreateTrackPointerInfo = true;
    Text delegate(Text) onTrackPointerInfo;
    void delegate(Text) onConfiguredTrackPointerInfo;
    void delegate(Text) onCreatedTrackPointerInfo;

    bool isTrackPointer = true;
    RGBA trackPointerColor;
    //RCTRL
    ComKeyName trackPointerAltKey = ComKeyName.key_lctrl;

    size_t labelNumberPrecision = 2;
    size_t prefLabelGlyphWidth = 4;

    protected
    {
        bool isStartTrackPointer;
    }

    this(float chartAreaWidth = 0, float chartAreaHeight = 0)
    {
        this.chartAreaWidth = chartAreaWidth;
        this.chartAreaHeight = chartAreaHeight;

        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout(0);
        layout.isAutoResize = true;
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadXYChartTheme;
    }

    void loadXYChartTheme()
    {
        auto chartSize = theme.controlDefaultHeight * 2;
        if (chartAreaWidth == 0)
        {
            chartAreaWidth = chartSize;
        }

        if (chartAreaHeight == 0)
        {
            chartAreaHeight = chartSize;
        }

        if (xAxisColor == RGBA.init)
        {
            xAxisColor = theme.colorWarning;
        }

        if (yAxisColor == RGBA.init)
        {
            yAxisColor = theme.colorWarning;
        }

        padding = theme.controlPadding;
    }

    override void create()
    {
        super.create;

        //TODO factory?
        import api.dm.gui.controls.containers.hbox : HBox;

        auto chartContentContainer = new HBox(0);
        //chartContentContainer.isDrawBounds = true;
        chartContentContainer.isResizeChildren = false;
        chartContentContainer.layout.isResizeChildren = false;
        addCreate(chartContentContainer);

        if (!yScale1 && isCreateYScale1)
        {
            auto ns = newYScale1(0, chartAreaHeight);
            yScale1 = !onNewYScale1 ? ns : onNewYScale1(ns);

            yScale1.isInvertX = true;
            //yScale1.isDrawFirstTick = false;
            yScale1.labelNumberPrecision = labelNumberPrecision;
            yScale1.isResizedByParent = false;
            yScale1.prefLabelGlyphWidth = prefLabelGlyphWidth;

            if (onConfiguredYScale1)
            {
                onConfiguredYScale1(yScale1);
            }

            if (!isShowYScale)
            {
                yScale1.isVisible = false;
            }

            chartContentContainer.addCreate(yScale1);

            if (onCreatedYScale1)
            {
                onCreatedYScale1(yScale1);
            }

        }

        if (!chartArea && isCreateChartArea)
        {
            auto cha = newChartArea;
            chartArea = !onNewChartArea ? cha : onNewChartArea(cha);

            chartArea.isResizedByParent = false;
            
            chartArea.width = chartAreaWidth;
            chartArea.height = chartAreaHeight;

            if (onConfiguredChartArea)
            {
                onConfiguredChartArea(chartArea);
            }

            chartContentContainer.addCreate(chartArea);

            if (onCreatedChartArea)
            {
                onCreatedChartArea(chartArea);
            }

        }

        if (!xScale1 && isCreateXScale1)
        {
            auto nsx = newXScale1(chartAreaWidth, 0);
            xScale1 = !onNewXScale1 ? nsx : onNewXScale1(nsx);

            xScale1.marginLeft = yScale1 ? yScale1.width : 0;
            xScale1.isDrawFirstTick = false;
            xScale1.isShowFirstLabelText = false;
            xScale1.labelNumberPrecision = labelNumberPrecision;
            xScale1.prefLabelGlyphWidth = prefLabelGlyphWidth;

            if (!isShowXScale)
            {
                xScale1.isVisible = false;
            }

            if (onConfiguredXScale1)
            {
                onConfiguredXScale1(xScale1);
            }

            addCreate(xScale1);

            if(onCreatedXScale1){
                onCreatedXScale1(xScale1);
            }

        }

        //auto xScaleRangeLimit = 50;
        //auto xScaleRangeMinLimit = 0.5;

        if (isScalable)
        {
            onPointerWheel ~= (ref e) {
                float scaleFactor = 1.5;
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
                float speedFactor = 100;
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

    float rangeX() => maxX - minX;
    float rangeY() => maxY - minY;

    protected float rangeXToWidth(float x, bool isUseOffsets = true, bool isUseScale = true)
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

        if (isUseScale)
        {
            x *= scaleX;
        }

        auto wX = (chartArea.width / rangeX) * x;
        //Clipping here can change the shape of the curve
        return wX;
    }

    protected float rangeYToHeight(float y, bool isUseOffsets = true, bool isUseScale = true)
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

        if (isUseScale)
        {
            y *= scaleY;
        }

        auto hY = (chartArea.height / rangeY) * y;
        return hY;
    }

    float widthToX(float w)
    {
        if (w < 0 || w > chartAreaWidth)
        {
            //TODO error?
            return 0;
        }
        return xScale1.minValue + (w * xScale1.range / chartAreaWidth);
    }

    float heightToY(float h)
    {
        if (h < 0 || h > chartAreaHeight)
        {
            //TODO error?
            return 0;
        }
        return yScale1.maxValue - (h * yScale1.range / chartAreaHeight);
    }

    protected Vec2d toChartAreaPos(float posX, float posY, bool isUseOffsets = true, bool isUseScale = true)
    {
        assert(chartArea);

        //TODO may be negative if the chart goes beyond the boundaries
        auto wX = rangeXToWidth(posX, isUseOffsets, isUseScale);
        auto hY = rangeYToHeight(posY, isUseOffsets, isUseScale);

        float newX = 0;
        float newY = 0;

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
                if (wX < 0)
                {
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
                if (hY < 0)
                {
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
            graphic.line(chartArea.x, zeroPos.y, chartArea.boundsRect.right, zeroPos.y, xAxisColor);
        }

        if (xScale1.minValue < 0 && xScale1.maxValue > 0)
        {
            graphic.line(zeroPos.x, chartArea.y, zeroPos.x, chartArea.boundsRect.bottom, yAxisColor);
        }
    }

    void drawGrid()
    {

        auto xTicks = xScale1.tickCount;
        auto yTicks = yScale1.tickCount;

        auto tickXDiff = chartAreaWidth / (xTicks - 1);
        float startX = 0;
        //TODO major;
        float tickW = xScale1.tickMinorWidth / 2.0;
        foreach (x; 0 .. xTicks)
        {
            auto tickPos = chartArea.x + startX - tickW;
            graphic.line(tickPos, chartArea.y, tickPos, chartArea.boundsRect.bottom, gridColor);
            startX += tickXDiff;
        }

        auto tickYDiff = chartAreaHeight / (yTicks - 1);
        float startY = 0;
        float tickH = yScale1.tickMinorHeight / 2.0;
        foreach (y; 0 .. yTicks)
        {
            float tickPos = chartArea.y + startY - tickH;
            graphic.line(chartArea.x, tickPos, chartArea.boundsRect.right, tickPos, gridColor);
            startY += tickYDiff;
        }

    }

    void trackPointer()
    {
        if (!isStartTrackPointer || !input.isPressedKey(trackPointerAltKey))
        {
            if (trackPointerInfo.isVisible)
            {
                trackPointerInfo.isVisible = false;
            }
            return;
        }

        if (!trackPointerInfo.isVisible)
        {
            trackPointerInfo.isVisible = true;
        }

        Vec2d pointerPos = input.pointerPos;
        auto dx = pointerPos.x - chartArea.x;
        auto dy = pointerPos.y - chartArea.y;
        if (dx < 0 || dy < 0)
        {
            return;
        }

        graphic.line(chartArea.x + dx, chartArea.y, chartArea.x + dx, chartArea.boundsRect.bottom, trackPointerColor);
        graphic.line(chartArea.x, chartArea.y + dy, chartArea.boundsRect.right, chartArea.y + dy, trackPointerColor);

        auto dxInfo = widthToX(dx);
        auto dyInfo = heightToY(dy);

        import std.format : format;

        trackPointerInfo.text = format("x:%.2f y:%.2f", dxInfo, dyInfo);
    }

    Container newChartArea()
    {
        return new Container;
    }

    HScaleDynamic newXScale1(float w, float h)
    {
        return new HScaleDynamic(w, h);
    }

    VScaleDynamic newYScale1(float w, float h)
    {
        return new VScaleDynamic(w, h);
    }
}
