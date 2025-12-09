module api.dm.gui.controls.meters.scales.base_drawable_scale;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.meters.scales.base_minmax_scale : BaseMinMaxScale;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.sprites2d.textures.vectors.vector_texture : VectorTexture;
import api.math.geom2.vec2 : Vec2f;
import api.math.geom2.rect2 : Rect2f;
import api.dm.gui.controls.texts.text : Text;
import api.dm.kit.assets.fonts.font_size : FontSize;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.geom2.line2 : Line2f;
import Math = api.math;

import std.conv : to;

/**
 * Authors: initkfs
 */
abstract class BaseDrawableScale : BaseMinMaxScale
{
    this(float width = 0, float height = 0)
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
        Line2f axisPos();

        Vec2f tickStartPos();
        float tickOffset();
        Vec2f tickStep(size_t i, Vec2f pos, float offsetTick);

        bool drawLabel(size_t labelIndex, size_t tickIndex, Vec2f pos, bool isMajorTick, float offsetTick);
    }

    Vec2f tickXY(Vec2f pos, float tickWidth, float tickHeight, bool isMajorTick)
    {
        auto tickX = pos.x - tickWidth / 2;
        auto tickY = pos.y - tickHeight / 2;
        return Vec2f(tickX, tickY);
    }

    bool drawTick(size_t i, Vec2f pos, bool isMajorTick, float offsetTick)
    {
        auto tickW = isMajorTick ? tickMajorWidth : tickMinorWidth;
        auto tickH = isMajorTick ? tickMajorHeight : tickMinorHeight;

        auto tickPos = tickXY(pos, tickW, tickH, isMajorTick);

        auto tickColor = isMajorTick ? theme.colorDanger : theme.colorAccent;

        graphic.fillRect(tickPos.x, tickPos.y, tickW, tickH, tickColor);
        return true;
    }

    void drawAxis(Vec2f start, Vec2f end, RGBA color)
    {
        graphic.line(start, end, color);
    }

    void drawScale()
    {
        if (!isCreated)
        {
            return;
        }

        drawScale(
            (Vec2f start, Vec2f end, RGBA) { drawAxis(start, end, axisColor); },
            (size_t i, Vec2f pos, bool isMajorTick, float offsetTick) {
            return drawTick(i, pos, isMajorTick, offsetTick);
        },
            (size_t labelIndex, size_t tickIndex, Vec2f pos, bool isMajorTick, float offsetTick) {
            return drawLabel(labelIndex, tickIndex, pos, isMajorTick, offsetTick);
        },
            (size_t i, Vec2f pos, float offsetTick) {
            return tickStep(i, pos, offsetTick);
        }
        );
    }

    void drawScale(
        scope void delegate(Vec2f, Vec2f, RGBA) onDrawAxis,
        scope bool delegate(size_t i, Vec2f pos, bool isMajorTick, float offsetTick) onDrawTick,
        scope bool delegate(size_t labelIndex, size_t tickIndex, Vec2f pos, bool isMajorTick, float offsetTick) onDrawLabel,
        scope Vec2f delegate(size_t i, Vec2f pos, float offsetTick) onTickStep
    )
    {
        if (!isCreated)
        {
            return;
        }

        if (isDrawAxis && onDrawAxis)
        {
            const Line2f pos = axisPos;
            onDrawAxis(pos.start, pos.end, axisColor);
        }

        auto count = tickCount;

        if (count < 2)
        {
            return;
        }

        const lastIndex = count - 1;

        auto offset = tickOffset;

        Vec2f startPos = tickStartPos;

        size_t labelCounter;
        bool isDrawTick;
        foreach (i; 0 .. count)
        {
            isDrawTick = true;

            bool isMajorTick = majorTickStep > 0 && ((i % majorTickStep) == 0);

            if (isShowFirstLastLabel && (i == 0 || i == count - 1))
            {
                isMajorTick = true;
            }

            if (i == 0)
            {
                isDrawTick = isDrawFirstTick;
                isMajorTick = isFirstTickMajorTick;
            }
            else if (i == lastIndex)
            {
                isDrawTick = isDrawLastTick;
                isMajorTick = isLastTickMajorTick;
            }

            if (isDrawTick && onDrawTick)
            {
                onDrawTick(i, startPos, isMajorTick, offset);
            }

            if (onDrawLabel)
            {
                bool isLabel = onDrawLabel(labelCounter, i, startPos, isMajorTick, offset);

                if (isLabel)
                {
                    labelCounter++;
                }
            }

            if (onTickStep)
            {
                startPos = onTickStep(i, startPos, offset);
            }
        }
    }

}
