module api.dm.gui.controls.scales.render_vscale;

import api.dm.gui.controls.scales.render_scale : RenderScale;
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
        double startY = !isInvert ? y : bounds.bottom;
        size_t majorTickCounter;
        foreach (i; 0 .. count)
        {
            bool isMajorTick = majorTickStep > 0 && ((i % majorTickStep) == 0);

            if (isShowFirstLastLabel && (i == 0 || i == count - 1))
            {
                isMajorTick = true;
            }

            auto tickW = isMajorTick ? tickMajorWidth : tickMinorWidth;
            auto tickH = isMajorTick ? tickMajorHeight : tickMinorHeight;

            auto tickX = bounds.right - tickW / 2;
            auto tickY = startY - tickH / 2;

            auto tickColor = isMajorTick ? graphics.theme.colorDanger : graphics.theme.colorAccent;

            graphics.fillRect(Vector2(tickX, tickY), tickW, tickH, tickColor);

            if (isMajorTick && (majorTickCounter < labels.length))
            {
                auto label = labels[majorTickCounter];
                auto labelX = x;
                auto labelY = startY - label.bounds.halfHeight;
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

            if(isInvert){
                startY -= tickOffset;
            }else {
                startY += tickOffset;
            }
        }
    }
}
