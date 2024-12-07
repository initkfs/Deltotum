module api.dm.gui.controls.meters.scales.base_drawable_scale;

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
import api.math.geom2.line2 : Line2d;
import Math = api.math;

import std.conv : to;

/**
 * Authors: initkfs
 */
abstract class BaseDrawableScale : BaseMinMaxScale
{
    this(double width = 0, double height = 0)
    {
        this._width = width;
        this._height = height;
    }

    override void loadTheme()
    {
        super.loadTheme;

        if (axisColor == RGBA.init)
        {
            axisColor = theme.colorDanger;
        }
    }

    abstract
    {
        Line2d axisPos();

        Vec2d tickStartPos();
        double tickOffset();
        Vec2d tickStep(size_t i, Vec2d pos, double offsetTick);

        bool drawLabel(size_t i, Vec2d pos, double tickWidth, double tickHeight, bool isMajorTick);
    }

    bool drawTick(size_t i, Vec2d pos, bool isMajorTick)
    {
        auto tickW = isMajorTick ? tickMajorWidth : tickMinorWidth;
        auto tickH = isMajorTick ? tickMajorHeight : tickMinorHeight;

        auto tickX = pos.x - tickW / 2;
        auto tickY = pos.y - tickH / 2;

        auto tickColor = isMajorTick ? theme.colorDanger : theme.colorAccent;

        graphics.fillRect(tickX, tickY, tickW, tickH, tickColor);
        return true;
    }

    void drawAxis(Vec2d start, Vec2d end, RGBA color)
    {
        graphics.line(start, end, color);
    }

    void drawScale()
    {
        if (!isCreated)
        {
            return;
        }

        if (isDrawAxis)
        {
            const Line2d pos = axisPos;
            drawAxis(pos.start, pos.end, axisColor);
        }

        auto count = tickCount;

        if (count < 1)
        {
            return;
        }

        auto offset = tickOffset;

        Vec2d startPos = tickStartPos;

        size_t labelCounter;
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
                drawTick(i, startPos, isMajorTick);
            }

            bool isLabel = drawLabel(labelCounter, startPos, tickMajorWidth, tickMajorHeight, isMajorTick);

            if (isLabel)
            {
                labelCounter++;
            }

            startPos = tickStep(i, startPos, offset);
        }
    }

}
