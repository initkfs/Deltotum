module api.dm.gui.controls.meters.scales.dynamics.base_scale_dynamic;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.meters.scales.base_minmax_scale : BaseMinMaxScale;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.sprites.sprites2d.textures.vectors.vector_texture : VectorTexture;
import api.math.geom2.vec2 : Vec2d;
import api.math.geom2.rect2 : Rect2d;
import api.dm.gui.controls.texts.text : Text;
import api.dm.kit.assets.fonts.font_size : FontSize;
import api.dm.kit.graphics.colors.rgba : RGBA;
import Math = api.math;

import std.conv : to;

/**
 * Authors: initkfs
 */
abstract class BaseScaleDynamic : BaseMinMaxScale
{
    protected
    {
        Text[] labelPool;
        Text[] labels;

        double prefLabelWidth = 0;
    }

    this(double width = 0, double height = 0)
    {
        this._width = width;
        this.height = height;
    }

    override void create()
    {
        super.create;

        createLabelPool;
        alignLabels;

        //TODO from class field?
        if (axisColor == RGBA.init)
        {
            axisColor = theme.colorDanger;
        }
    }

    override bool recreate()
    {
        super.recreate;
        createLabelPool;
        return true;
    }

    void rescaleMax(double value, bool isRecreate = true)
    {
        maxValue = value;
        if (isRecreate)
        {
            recreate;
        }
    }

    void createLabelPool()
    {
        foreach (poolLabel; labelPool)
        {
            poolLabel.text = "--";
            poolLabel.isVisible = false;
        }

        size_t majorTickCount = tickCount / majorTickStep;

        if ((majorTickCount != tickCount) && isShowFirstLastLabel)
        {
            majorTickCount++;
            if (majorTickStep % 2 != 0)
            {
                majorTickCount++;
            }
        }

        size_t poolDiff = majorTickCount > labelPool.length ? majorTickCount - labelPool.length : 0;

        foreach (i; 0 .. poolDiff)
        {
            auto label = new Text("!");
            label.fontSize = FontSize.small;
            label.isLayoutManaged = false;
            label.isVisible = false;
            addCreate(label);
            labelPool ~= label;
        }

        labels = labelPool[0 .. majorTickCount];
        auto lastIndex = labels.length - 1;

        //TODO log
        // import std;
        // writefln("min:%s, max:%s, c: %s, mc: %s, labels: %s", minValue, maxValue, tickCount, majorTickCount, labels.length);

        //TODO one loop
        foreach (i, label; labels)
        {
            //TODO cache
            if (isShowFirstLastLabel)
            {
                if (i == 0)
                {
                    label.text = formatLabelValue(minValue);
                    continue;
                }
                else if (i == lastIndex)
                {
                    label.text = formatLabelValue(maxValue);
                    break;
                }
            }
            auto tickValue = minValue + i * majorTickStep * valueStep;
            label.text = formatLabelValue(tickValue);
        }
    }

    void alignLabels()
    {

        if (labelPool.length == 0)
        {
            return;
        }

        import std.range : repeat, take;
        import std.array : join;

        auto pattern = "0"d.repeat.take(prefLabelGlyphWidth).join;

        foreach (label; labels)
        {
            label.width = label.calcTextWidth(pattern, label.fontSize);
        }
    }

    abstract double tickOffset();
    abstract Vec2d tickStep(size_t i, double startX, double startY, double offsetTick);

    abstract Vec2d labelXY(size_t i, double startX, double startY, Text label, double tickWidth, double tickHeight);

    abstract Vec2d axisStartPos();
    abstract Vec2d axisEndPos();

    abstract Vec2d meterStartPos();

    void drawTick(size_t i, double startX, double startY, double w, double h, RGBA color)
    {
        auto tickX = startX - w / 2;
        auto tickY = startY - h / 2;

        graphics.fillRect(tickX, tickY, w, h, color);
    }

    override void drawContent()
    {
        super.drawContent;

        if (!isCreated)
        {
            return;
        }

        if (isDrawAxis)
        {
            Vec2d startPos = axisStartPos;
            Vec2d endPos = axisEndPos;
            graphics.line(startPos, endPos, axisColor);
        }

        auto count = tickCount;

        if (count < 1)
        {
            return;
        }

        auto tickOffsetValue = tickOffset;

        const startPosV = meterStartPos;

        double startX = startPosV.x;
        double startY = startPosV.y;

        size_t majorTickCounter;
        bool isDrawTick;
        foreach (i; 0 .. count)
        {
            isDrawTick = true;

            if (i == 0)
            {
                if (!isDrawFirstTick)
                {
                    isDrawTick = false;
                }
            }

            bool isMajorTick = majorTickStep > 0 && ((i % majorTickStep) == 0);

            if (isShowFirstLastLabel && (i == 0 || i == count - 1))
            {
                isMajorTick = true;
            }

            if (isDrawTick)
            {
                auto tickW = isMajorTick ? tickMajorWidth : tickMinorWidth;
                auto tickH = isMajorTick ? tickMajorHeight : tickMinorHeight;

                auto tickColor = isMajorTick ? theme.colorDanger : theme.colorAccent;

                drawTick(i, startX, startY, tickW, tickH, tickColor);
            }

            if (isMajorTick && (majorTickCounter < labels.length))
            {
                auto label = labels[majorTickCounter];

                const labelPos = labelXY(i, startX, startY, label, tickMajorWidth, tickMajorHeight);

                auto labelX = labelPos.x;
                auto labelY = labelPos.y;

                label.xy(labelX, labelY);

                if (!label.isVisible)
                {
                    if (i == 0)
                    {
                        if (isShowFirstLabelText)
                        {
                            label.isVisible = true;
                        }
                    }
                    else
                    {
                        label.isVisible = true;
                    }

                }
            }

            if (isMajorTick)
            {
                majorTickCounter++;
            }

            const stepValue = tickStep(i, startX, startY, tickOffsetValue);
            startX = stepValue.x;
            startY = stepValue.y;
        }
    }

}
