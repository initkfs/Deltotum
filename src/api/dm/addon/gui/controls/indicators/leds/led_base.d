module api.dm.addon.gui.controls.indicators.leds.led_base;

import api.dm.kit.sprites.sprite : Sprite;
import api.dm.gui.controls.control : Control;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites.textures.texture : Texture;
import api.dm.gui.containers.vbox : VBox;
import api.dm.gui.containers.hbox : HBox;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.colors.hsv : HSV;
import api.math.insets : Insets;

import ColorProcessor = api.dm.kit.graphics.colors.processing.color_processor;

/**
 * Authors: initkfs
 */
class LedBase : Control
{
    RGBA colorHue;

    this(RGBA colorHue, double width, double height)
    {
        this.width = width;
        this.height = height;

        import api.dm.kit.sprites.layouts.center_layout : CenterLayout;

        layout = new CenterLayout;
        this.colorHue = colorHue;

        isOpacityForChildren = true;
    }

    abstract Sprite newLayerShape(GraphicStyle style, double layerInnerPadding, double blurSize);
    abstract Sprite createLedLayer();

    double calcLayerPadding()
    {
        const padding = (width * 3) / 35;
        return padding;
    }

    protected void setColorProcessing(T)(T shape, double blurSize)
    {
        import std.conv : to;

        shape.onSurfaceIsContinue = (surf) {
            RGBA[][] buff = surfaceToBuffer(surf);
            RGBA[][] gaussBuff = ColorProcessor.boxblur(buff, blurSize.to!size_t);

            auto err = surf.setPixels((x, y, color) {
                auto buffColor = gaussBuff[y][x];
                color[0] = buffColor.r;
                color[1] = buffColor.g;
                color[2] = buffColor.b;
                color[3] = buffColor.aByte;
                return true;
            });
            if(err){
                logger.error(err.toString);
            }

            return true;
        };
    }

    HSV getLayersColorHSV()
    {
        auto hsvColor = colorHue.toHSV;
        hsvColor.saturation = 1;
        hsvColor.value = 1;
        return hsvColor;
    }

    HSV getBottomColorHSV(HSV color)
    {
        color.value = 0.8;
        return color;
    }

    HSV getMiddleColorHSV(HSV color)
    {
        return color;
    }

    HSV getTopColorHSV(HSV color)
    {
        color.saturation = 0.5;
        return color;
    }

    protected GraphicStyle getLayersStyle()
    {
        auto style = createStyle;
        style.isFill = true;
        return style;
    }

    GraphicStyle getBottomLayerStyle(HSV color)
    {
        auto style = getLayersStyle;
        style.color = getBottomColorHSV(color).toRGBA;
        return style;
    }

    GraphicStyle getMiddleLayerStyle(HSV color)
    {
        auto style = getLayersStyle;
        style.color = getMiddleColorHSV(color).toRGBA;
        return style;
    }

    GraphicStyle getTopLayerStyle(HSV color)
    {
        auto style = getLayersStyle;
        style.color = getTopColorHSV(color).toRGBA;
        return style;
    }

    protected Sprite createLayer(GraphicStyle style, double layerInnerPadding, double blurSize)
    {
        auto shape = newLayerShape(style, layerInnerPadding, blurSize);
        if (!shape.isCreated)
        {
            if (!shape.isBuilt)
            {
                build(shape);

                shape.initialize;
                assert(shape.isInitialized);
            }

            shape.create;
            assert(shape.isCreated);
        }

        return shape;
    }

    Texture composeLayers(Sprite[] layers)
    {
        auto texture = new Texture(width, height);
        build(texture);
        texture.createTargetRGBA32;

        import api.dm.com.graphics.com_blend_mode : ComBlendMode;

        texture.blendMode = ComBlendMode.blend;

        texture.setRendererTarget;
        scope (exit)
        {
            texture.resetRendererTarget;
        }

        foreach (layer; layers)
        {
            layer.draw;
        }
        return texture;
    }

    override void create()
    {
        super.create;

        auto ledLayer = createLedLayer;
        addCreate(ledLayer);
    }
}
