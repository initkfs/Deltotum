module api.dm.gui.controls.indicators.leds.base_led;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.gui.controls.containers.vbox : VBox;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.colors.hsla : HSLA;
import api.math.pos2.insets : Insets;

import ColorProcessor = api.dm.kit.graphics.colors.processings.processing;

/**
 * Authors: initkfs
 */
class BaseLed : Control
{
    RGBA colorHue;

    this(RGBA colorHue, double width = 0, double height = 0)
    {
        this.width = width;
        this.height = height;

        this.colorHue = colorHue;

        import api.dm.kit.sprites2d.layouts.center_layout : CenterLayout;

        layout = new CenterLayout;
        isOpacityForChildren = true;
    }

    override void loadTheme()
    {
        super.loadTheme;
    }

    abstract Sprite2d newLayerShape(GraphicStyle style, double layerInnerPadding, double blurSize);
    abstract Sprite2d createLedLayer();

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
            if (err)
            {
                logger.error(err.toString);
            }

            return true;
        };
    }

    HSLA layersColor()
    {
        auto hsvColor = colorHue.toHSLA;
        hsvColor.s = 1;
        hsvColor.l = 0.5;
        return hsvColor;
    }

    HSLA bottomColor(HSLA color)
    {
        color.l = 0.35;
        return color;
    }

    HSLA middleColor(HSLA color)
    {
        return color;
    }

    HSLA topColor(HSLA color)
    {
        color.l = 0.95;
        return color;
    }

    double bottomLayerOpacity() => 1;
    double middleLayerOpacity() => 0.8;
    double topLayerOpacity() => 0.2;

    protected GraphicStyle layersStyle()
    {
        auto style = createStyle;
        style.isFill = true;
        return style;
    }

    GraphicStyle bottomLayerStyle(HSLA color)
    {
        auto style = layersStyle;
        style.color = bottomColor(color).toRGBA;
        return style;
    }

    GraphicStyle middleLayerStyle(HSLA color)
    {
        auto style = layersStyle;
        style.color = middleColor(color).toRGBA;
        return style;
    }

    GraphicStyle topLayerStyle(HSLA color)
    {
        auto style = layersStyle;
        style.color = topColor(color).toRGBA;
        return style;
    }

    protected Sprite2d createLayer(GraphicStyle style, double layerSize, double blurSize)
    {
        auto shape = newLayerShape(style, layerSize, blurSize);
        if (!shape.isBuilt)
        {
            buildInit(shape);
        }

        if (!shape.isCreated)
        {
            shape.create;
            assert(shape.isCreated);
        }

        return shape;
    }

    Texture2d composeLayers(Sprite2d[] layers)
    {
        auto texture = new Texture2d(width, height);
        buildInitCreate(texture);

        texture.createTargetRGBA32;
        texture.blendModeBlend;
        texture.setRendererTarget;
        scope (exit)
        {
            texture.restoreRendererTarget;
        }

        graphic.clearTransparent;

        foreach (layer; layers)
        {
            texture.centering(layer);
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
