module api.dm.gui.controls.indicators.leds.led_icon;

import api.dm.gui.controls.indicators.leds.base_led : BaseLed;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.gui.controls.containers.vbox : VBox;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.colors.hsva : HSVA;
import api.math.pos2.insets : Insets;
import api.dm.kit.sprites2d.images.image : Image;

import std.conv : to;

import ColorProcessor = api.dm.kit.graphics.colors.processings.processing;

/**
 * Authors: initkfs
 */
class LedIcon : BaseLed
{
    dchar iconName;

    this(dchar iconName, RGBA colorHue = RGBA.red, float width = 0, float height = 0)
    {
        super(colorHue, width, height);
        this.iconName = iconName;

        import api.dm.kit.sprites2d.layouts.managed_layout : ManagedLayout;

        layout = new ManagedLayout;
        layout.isAutoResize = true;
    }

    override void loadTheme()
    {
        width = theme.iconSize;
        height = theme.iconSize;
    }

    override protected Sprite2d newLayerShape(GraphicStyle style, float iconSize, float blurSize)
    {
        //TODO load from surface
        RGBA[][] buff = createIconBuffer(iconName, colorHue);

        if (buff.length == 0)
        {
            logger.error("Invalid buffer for led icon");

            import api.dm.kit.sprites2d.shapes.rectangle : Rectangle;

            return new Rectangle(iconSize, iconSize);
        }

        import api.dm.kit.sprites2d.images.image : Image;

        auto image = new Image;
        buildInit(image);

        auto blurBuff = ColorProcessor.boxblur(buff, blurSize.to!size_t);
        image.load(blurBuff);
        image.blendModeBlend;

        return image;
    }

    override Sprite2d createLedLayer()
    {
        auto color = layersColor;
        const bottomPadding = width * 0.8;
        const topPadding = width * 0.65;

        auto bottomLayerStyle = bottomLayerStyle(color);
        auto bottomLayer = createLayer(bottomLayerStyle, bottomPadding, 6);
        //bottomLayer.opacity = bottomLayerOpacity;
        scope (exit)
        {
            bottomLayer.dispose;
        }

        auto topLayerStyle = middleLayerStyle(color);
        auto topLayer = createLayer(topLayerStyle, topPadding, 2);
        // topLayer.opacity = 0.5;
        scope (exit)
        {
            topLayer.dispose;
        }

        auto ledTexture = composeLayers([bottomLayer, topLayer]);
        return ledTexture;
    }

    override void create()
    {
        super.create;
    }
}
