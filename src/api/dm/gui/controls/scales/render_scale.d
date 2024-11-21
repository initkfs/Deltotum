module api.dm.gui.controls.scales.render_scale;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.sprites.textures.texture : Texture;
import api.dm.kit.sprites.textures.vectors.vector_texture : VectorTexture;
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
class RenderScale : Control
{
    double minValue = 0;
    double maxValue = 1;

    double valueStep = 0.05;

    size_t majorTickStep = 1;

    bool isShowFirstLastLabel = true;

    size_t tickMinorWidth;
    size_t tickMinorHeight;
    size_t tickMajorWidth;
    size_t tickMajorHeight;

    bool isShowFirstLabelText = true;

    bool isDrawFirstTick = true;

    bool isInvertX;
    bool isInvertY;

    bool isDrawAxis = true;
    RGBA axisColor;

    size_t labelNumberPrecision = 2;
    size_t prefLabelGlyphWidth = 4;

    protected
    {
        Text[] labelPool;
        Text[] labels;

        double prefLabelWidth = 0;
    }

    this(double width, double height)
    {
        this._width = width;
        this._height = height;

        import api.dm.kit.sprites.layouts.center_layout : CenterLayout;

        this.layout = new CenterLayout;
    }

    double range()
    {
        assert(minValue < maxValue);
        return maxValue - minValue;
    }

    size_t tickCount()
    {
        size_t ticksCount = Math.round(range / valueStep).to!size_t;
        return ticksCount + 1;
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

    override void recreate()
    {
        super.recreate;
        createLabelPool;
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

    void alignLabels(){
        if(labelPool.length == 0){
            return;
        }
        auto proto = labelPool[0];

        import std.range: repeat, take;
        import std.array: join;

        auto pattern = "0"d.repeat.take(prefLabelGlyphWidth).join;

        foreach (label; labels)
        {
            label.width = label.calcTextWidth(pattern, label.fontSize);
        }
    }

    dstring formatLabelValue(double value)
    {
        import std.conv : to;
        import std.math.rounding : trunc;

        if ((value - value.trunc) == 0)
        {
            return value.to!dstring;
        }
        import std.format : format;
        import std.math.operations: isClose;

        auto zeroPrec = 1.0 / (10 ^^ (labelNumberPrecision + 1));
        if(isClose(value, 0.0, 0.0, zeroPrec)){
            return "0"d;
        }

        return format("%.*f"d, labelNumberPrecision, value);
    }

    override void dispose()
    {
        super.dispose;
    }
}
