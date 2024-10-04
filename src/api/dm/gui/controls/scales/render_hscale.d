module api.dm.gui.controls.scales.render_hscale;

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
class RenderHScale : RenderScale
{
    this(double width, double height)
    {
        super(width, height);

        tickMinorWidth = 2;
        tickMinorHeight = 6;
        tickMajorWidth = 2;
        tickMajorHeight = 12;
    }

    override void drawContent()
    {
        super.drawContent;

        if (!isCreated)
        {
            return;
        }

        auto count = tickCount;

        if (count < 1)
        {
            return;
        }

        auto tickOffset = width / (tickCount - 1);
        double startX = !isInvertX ? x : bounds.right;
        double startY = !isInvertY ? y : bounds.bottom;
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

                auto tickColor = isMajorTick ? graphics.theme.colorDanger
                    : graphics.theme.colorAccent;

                graphics.fillRect(Vec2d(tickX, tickY), tickW, tickH, tickColor);
            }

            if (isMajorTick && (majorTickCounter < labels.length))
            {
                auto label = labels[majorTickCounter];
                auto labelX = startX - label.bounds.halfWidth;
                auto labelY = !isInvertY ? startY + tickMajorHeight / 2 : startY - label.height - tickMajorHeight / 2;
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

            if (isInvertX)
            {
                startX -= tickOffset;
            }
            else
            {
                startX += tickOffset;
            }
        }

        if (isDrawAxis)
        {
            auto startPosY = !isInvertY ? y : bounds.bottom;
            graphics.line(x, startPosY, bounds.right, startPosY, axisColor);
        }
    }
}
