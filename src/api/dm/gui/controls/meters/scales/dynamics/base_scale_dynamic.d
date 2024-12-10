module api.dm.gui.controls.meters.scales.dynamics.base_scale_dynamic;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.meters.scales.base_drawable_scale : BaseDrawableScale;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.sprites2d.textures.vectors.vector_texture : VectorTexture;
import api.math.geom2.vec2 : Vec2d;
import api.math.geom2.rect2 : Rect2d;
import api.dm.gui.controls.texts.text : Text;
import api.dm.kit.assets.fonts.font_size : FontSize;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.geom2.line2 : Line2d;
import Math = api.math;

import std.conv : to;

/**
 * Authors: initkfs
 */
abstract class BaseScaleDynamic : BaseDrawableScale
{
    protected
    {
        Text[] labelPool;
        Text[] labels;

        double prefLabelWidth = 0;

        double maxLabelWidth = 0;
        double maxLabelHeight = 0;
    }

    this(double width = 0, double height = 0)
    {
        super(width, height);

        isResizeChildrenIfNoLayout = false;
    }

    override void create()
    {
        super.create;

        createLabelPool;
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
            label.isResizedByParent = false;

            // label.boundsColor = RGBA.yellow;
            // label.isDrawBounds = true;

            addCreate(label);
            labelPool ~= label;
        }

        labels = labelPool[0 .. majorTickCount];
        auto lastIndex = labels.length - 1;

        //TODO log
        // import std;
        // writefln("min:%s, max:%s, c: %s, mc: %s, labels: %s", minValue, maxValue, tickCount, majorTickCount, labels.length);

        //TODO one loop
        double maxW = 0;
        double maxH = 0;
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
            label.updateRows(isForce : true);

            const bounds = label.boundsRect;
            if(bounds.width > maxW){
                maxW = bounds.width;
            }

            if(bounds.height > maxH){
                maxH = bounds.height;
            }
        }

        maxLabelWidth = maxW;
        maxLabelHeight = maxH;
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

    void showLabelIsNeed(size_t i, Text label)
    {
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

    override void drawContent()
    {
        super.drawContent;

        drawScale;
    }

}
