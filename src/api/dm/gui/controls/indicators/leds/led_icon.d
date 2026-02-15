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
import IconName = api.dm.gui.icons.icon_name;
import api.dm.kit.sprites2d.images.image : Image;

import std.conv : to;

import ColorProcessor = api.dm.kit.graphics.colors.processings.processing;

/**
 * Authors: initkfs
 */
class LedIcon : BaseLed
{
    string iconName;

    this(string iconName, RGBA colorHue = RGBA.red, float width = 0, float height = 0)
    {
        super(colorHue, width, height);
        this.iconName = iconName;
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadLedIconTheme;
    }

    void loadLedIconTheme()
    {
        auto ledSize = theme.iconSize * 2;
        if (width == 0)
        {
            initWidth = ledSize;
        }

        if (height == 0)
        {
            initHeight = ledSize;
        }
    }

    override protected Sprite2d newLayerShape(GraphicStyle style, float iconSize, float blurSize)
    {
        auto buffSize = iconSize.to!size_t;
        RGBA[][] buff = new RGBA[][](buffSize, buffSize);

        auto icon = createIcon(iconName, iconSize, (x, y, color) {
            color.r = style.fillColor.r;
            color.g = style.fillColor.g;
            color.b = style.fillColor.b;
            buff[y][x] = color;
            return color;
        });

        import api.dm.kit.sprites2d.images.image : Image;

        if (auto image = cast(Image) icon)
        {
            auto blurBuff = ColorProcessor.boxblur(buff, blurSize.to!size_t);
            image.load(blurBuff);
            image.blendModeBlend;
        }
        else
        {
            logger.error("Invalid icon received, expected image: " ~ icon.toString);
        }

        return icon;
    }

    override Sprite2d createLedLayer()
    {
        auto color = layersColor;
        const bottomPadding = width * 0.8;
        const topPadding = width * 0.65;

        auto bottomLayerStyle = bottomLayerStyle(color);
        auto bottomLayer = createLayer(bottomLayerStyle, bottomPadding, 6);
        //bottomLayer.opacity = bottomLayerOpacity;
        scope(exit){
            bottomLayer.dispose;
        }

        auto topLayerStyle = middleLayerStyle(color);
        auto topLayer = createLayer(topLayerStyle, topPadding, 2);
        // topLayer.opacity = 0.5;
        scope(exit){
            topLayer.dispose;
        }

        auto ledTexture = composeLayers([bottomLayer, topLayer]);
        return ledTexture;
    }

    override void create()
    {
        super.create;

        // auto hsvColor = colorHue.toHSVA;
        // hsvColor.s = 1;
        // hsvColor.value = 1;

        // auto bottomHsvColor = hsvColor;
        // bottomHsvColor.value = 0.8;
        // bottomHsvColor.s = 0.7;
        // auto middleHsvColor = hsvColor;
        // auto topHsvColor = hsvColor;
        // topHsvColor.s = 0.1;

        // auto style = createStyle;
        // style.isFill = true;
        // style.color = bottomLayerColor;

        // const padding = calcLayerPadding;

        // auto bottomLayer = newLayer(style, padding * 4);
        // window.showingTasks ~= (dt) { bottomLayer.dispose; };

        // auto style2 = createStyle;
        // style2.isFill = true;
        // style2.color = middleLayerColor;

        // auto middleLayer = newLayer(style2, padding * 2);
        // window.showingTasks ~= (dt) { middleLayer.dispose; };

        // auto style3 = createStyle;
        // style3.isFill = true;
        // style3.color = topLayerColor;

        // auto topLayer = newLayer(style3, padding);

    }
}
