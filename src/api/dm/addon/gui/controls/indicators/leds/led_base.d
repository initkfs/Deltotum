module api.dm.addon.gui.controls.indicators.leds.led_base;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.gui.controls.containers.vbox : VBox;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.colors.hsva : HSVA;
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

        import api.dm.kit.sprites2d.layouts.center_layout : CenterLayout;

        layout = new CenterLayout;
        this.colorHue = colorHue;

        isOpacityForChildren = true;
    }

    abstract Sprite2d newLayerShape(GraphicStyle style, double layerInnerPadding, double blurSize);
    abstract Sprite2d createLedLayer();

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

    HSVA getLayersColorHSV()
    {
        auto hsvColor = colorHue.toHSVA;
        hsvColor.saturation = 1;
        hsvColor.value = 1;
        return hsvColor;
    }

    HSVA getBottomColorHSV(HSVA color)
    {
        color.value = 0.8;
        return color;
    }

    HSVA getMiddleColorHSV(HSVA color)
    {
        return color;
    }

    HSVA getTopColorHSV(HSVA color)
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

    GraphicStyle getBottomLayerStyle(HSVA color)
    {
        auto style = getLayersStyle;
        style.color = getBottomColorHSV(color).toRGBA;
        return style;
    }

    GraphicStyle getMiddleLayerStyle(HSVA color)
    {
        auto style = getLayersStyle;
        style.color = getMiddleColorHSV(color).toRGBA;
        return style;
    }

    GraphicStyle getTopLayerStyle(HSVA color)
    {
        auto style = getLayersStyle;
        style.color = getTopColorHSV(color).toRGBA;
        return style;
    }

    protected Sprite2d createLayer(GraphicStyle style, double layerInnerPadding, double blurSize)
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

    Texture2d composeLayers(Sprite2d[] layers)
    {
        auto texture = new Texture2d(width, height);
        build(texture);
        texture.createTargetRGBA32;

        import api.dm.com.graphics.com_blend_mode : ComBlendMode;

        texture.blendMode = ComBlendMode.blend;

        texture.setRendererTarget;
        scope (exit)
        {
            texture.restoreRendererTarget;
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
