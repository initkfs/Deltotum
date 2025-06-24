module api.dm.gui.controls.indicators.leds.led;

import api.dm.gui.controls.indicators.leds.base_led : BaseLed;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.colors.hsva : HSVA;
import api.math.pos2.insets : Insets;

import ColorProcessor = api.dm.kit.graphics.colors.processing.color_processor;

import std.conv : to;

/**
 * Authors: initkfs
 */
class Led : BaseLed
{
    this(RGBA colorHue = RGBA.red, double width = 0, double height = 0)
    {
        super(colorHue, width, height);
    }

    override protected Sprite2d newLayerShape(GraphicStyle style, double layerInnerPadding, double blurSize)
    {
        auto diameter = layerInnerPadding;

        if (!platform.cap.isVectorGraphics)
        {
            return theme.circleShape(diameter, style);
        }

        import api.dm.kit.sprites2d.textures.vectors.shapes.vcircle : VCircle;

        auto shape = new VCircle(diameter / 2.0, style);
        setColorProcessing(shape, blurSize);
        return shape;
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadLedTheme;
    }

    void loadLedTheme()
    {
        auto ledSize = theme.iconSize * 1.5;
        if (width == 0)
        {
            initWidth = ledSize;
        }

        if (height == 0)
        {
            initHeight = ledSize;
        }
    }

    override Sprite2d createLedLayer()
    {
        const hsvColor = layersColor;
        const bottomPadding = width * 0.8;
        const middlePadding = bottomPadding * 0.7;
        const topPadding = middlePadding * 0.6;

        auto bottomLayerStyle = bottomLayerStyle(hsvColor);
        auto bottomLayer = createLayer(bottomLayerStyle, bottomPadding, 8);
        bottomLayer.opacity = bottomLayerOpacity;
        scope (exit)
        {
            bottomLayer.dispose;
        }

        auto middleLayerStyle = middleLayerStyle(hsvColor);
        auto middleLayer = createLayer(middleLayerStyle, middlePadding, 4);
        middleLayer.opacity = middleLayerOpacity;
        scope(exit){
            middleLayer.dispose;
        }

        auto topLayerStyle = topLayerStyle(hsvColor);
        auto topLayer = createLayer(topLayerStyle, topPadding, 3);
        topLayer.opacity = topLayerOpacity;
        scope(exit){
            topLayer.dispose;
        }

        Sprite2d[3] layers = [bottomLayer, middleLayer, topLayer];

        auto ledTexture = composeLayers(layers[]);
        return ledTexture;
    }
}
