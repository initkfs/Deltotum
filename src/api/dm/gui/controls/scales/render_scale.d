module api.dm.gui.controls.scales.render_scale;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.sprites.textures.texture : Texture;
import api.dm.kit.sprites.textures.vectors.vector_texture : VectorTexture;
import api.math.vector2 : Vector2;
import api.math.rect2d : Rect2d;
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

    size_t majorTickStep = 5;

    bool isShowFirstLastLabel = true;

    size_t tickMinorWidth;
    size_t tickMinorHeight;
    size_t tickMajorWidth;
    size_t tickMajorHeight;

    bool isInvert;

    protected
    {
        Text[] labelPool;
        Text[] labels;
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
        size_t ticksCount = (range / valueStep).to!size_t;
        return ticksCount + 1;
    }

    override void create()
    {
        super.create;
        createLabelPool;
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
                    label.text = minValue.to!dstring;
                    continue;
                }
                else if (i == lastIndex)
                {
                    label.text = maxValue.to!dstring;
                    break;
                }
            }
            //TODO replace with format specifier
            import std.math.rounding: trunc;
            auto tickValue = minValue + i * majorTickStep * valueStep;
            if((tickValue - tickValue.trunc) == 0){
                label.text = tickValue.to!dstring;
            }else {
                import std.format: format;
                label.text = format("%.2f"d, tickValue);
            }
            
        }
    }

    override void dispose()
    {
        super.dispose;
    }
}
