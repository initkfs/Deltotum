module app.dm.addon.gui.controls.indicators.leds.led;

import app.dm.addon.gui.controls.indicators.leds.led_base : LedBase;
import app.dm.kit.sprites.sprite : Sprite;
import app.dm.gui.controls.control : Control;
import app.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import app.dm.kit.sprites.textures.texture : Texture;
import app.dm.gui.containers.vbox : VBox;
import app.dm.gui.containers.hbox : HBox;
import app.dm.kit.graphics.colors.rgba : RGBA;
import app.dm.kit.graphics.colors.hsv : HSV;
import app.dm.math.insets : Insets;

import ColorProcessor = app.dm.kit.graphics.colors.processing.color_processor;

import std.conv : to;

/**
 * Authors: initkfs
 */
class Led : LedBase
{
    this(RGBA colorHue = RGBA.red, double width = 35, double height = 35)
    {
        super(colorHue, width, height);
    }

    override protected Sprite newLayerShape(GraphicStyle style, double layerInnerPadding, double blurSize)
    {
        import app.dm.kit.sprites.textures.vectors.shapes.vcircle : VCircle;

        auto shape = new VCircle(width / 2 - layerInnerPadding, style, width, height);
        setColorProcessing(shape, blurSize);
        return shape;
    }

    override Sprite createLedLayer()
    {
        const hsvColor = getLayersColorHSV;
        const padding = calcLayerPadding;

        auto bottomLayerStyle = getBottomLayerStyle(hsvColor);
        auto bottomLayer = createLayer(bottomLayerStyle, padding, padding * 2);
        window.showingTasks ~= (dt) { bottomLayer.dispose; };

        auto middleLayerStyle = getMiddleLayerStyle(hsvColor);
        auto middleLayer = createLayer(middleLayerStyle, padding * 2, padding * 4);
        window.showingTasks ~= (dt) { middleLayer.dispose; };

        auto topLayerStyle = getTopLayerStyle(hsvColor);
        auto topLayer = createLayer(topLayerStyle, padding * 3, padding * 4);
        window.showingTasks ~= (dt) { topLayer.dispose; };

        auto ledTexture = composeLayers([bottomLayer, middleLayer, topLayer]);
        return ledTexture;
    }
}
