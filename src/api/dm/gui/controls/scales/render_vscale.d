module api.dm.gui.controls.scales.render_vscale;

import api.dm.gui.controls.scales.render_scale : RenderScale;
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
class RenderVScale : RenderScale
{
    this(double width, double height)
    {
        super(width, height);

        tickMinorWidth = 6;
        tickMinorHeight = 2;
        tickMajorWidth = 12;
        tickMajorHeight = 2;
    }

    override void drawContent()
    {
        super.drawContent;

        if (!isCreated)
        {
            return;
        }

        auto count = tickCount;

        auto tickOffset = height / (tickCount - 1);
        double startY = !isInvertY ? y : rectBounds.bottom;
        double startX = !isInvertX ? rectBounds.right : x;
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

                auto tickX = startX - tickW / 2;
                auto tickY = startY - tickH / 2;

                auto tickColor = isMajorTick ? theme.colorDanger
                    : theme.colorAccent;

                graphics.fillRect(Vec2d(tickX, tickY), tickW, tickH, tickColor);
            }

            if (isMajorTick && (majorTickCounter < labels.length))
            {
                auto label = labels[majorTickCounter];
                auto labelX = !isInvertX ? x - tickMajorWidth -5 : rectBounds.right;
                auto labelY = startY - label.rectBounds.halfHeight;
                label.xy(labelX, labelY);
                if (!label.isVisible)
                {
                    label.isVisible = true;
                }
            }

            if (isMajorTick)
            {
                majorTickCounter++;
            }

            if (isInvertY)
            {
                startY -= tickOffset;
            }
            else
            {
                startY += tickOffset;
            }
        }

        if (isDrawAxis)
        {
            auto startPosX = !isInvertX ? rectBounds.right : x;
            graphics.line(startPosX, y, startPosX, rectBounds.bottom, axisColor);
        }
    }
}
