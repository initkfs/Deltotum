module dm.addon.gui.controls.indicators.leds.led_icon;

import dm.addon.gui.controls.indicators.leds.led_base : LedBase;
import dm.kit.sprites.sprite : Sprite;
import dm.gui.controls.control : Control;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;
import dm.kit.sprites.textures.texture : Texture;
import dm.gui.containers.vbox : VBox;
import dm.gui.containers.hbox : HBox;
import dm.kit.graphics.colors.rgba : RGBA;
import dm.kit.graphics.colors.hsv : HSV;
import dm.math.insets : Insets;
import IconName = dm.kit.graphics.themes.icons.icon_name;
import dm.kit.sprites.images.image : Image;

import std.conv : to;

import ColorProcessor = dm.kit.graphics.colors.processing.color_processor;

/**
 * Authors: initkfs
 */
class LedIcon : LedBase
{
    string iconName;

    this(string iconName, RGBA colorHue = RGBA.red, double width = 35, double height = 35)
    {
        super(colorHue, width, height);
        this.iconName = iconName;
    }

    override protected Sprite newLayerShape(GraphicStyle style, double layerInnerPadding, double blurSize)
    {
        const size_t iconSize = cast(size_t)(width);
        const mustBeIconData = graphics.theme.iconData(iconName);
        if (mustBeIconData.isNull)
        {
            //TODO placeholder?
            throw new Exception("Not found icon data for icon: ", iconName);
        }

        const string iconData = mustBeIconData.get;

        auto icon = new Image();
        build(icon);
        icon.initialize;

        RGBA[][] buff = new RGBA[][](iconSize, iconSize);
        icon.colorProcessor = (x, y, color) {
            color.r = style.fillColor.r;
            color.g = style.fillColor.g;
            color.b = style.fillColor.b;
            buff[y][x] = color;
            return color;
        };

        icon.loadRaw(iconData.to!(const(void[])), cast(int) iconSize, cast(int) iconSize);

        auto blurBuff = ColorProcessor.boxblur(buff, blurSize.to!size_t);
        icon.load(blurBuff);
        icon.blendModeBlend;

        return icon;
    }

    override Sprite createLedLayer()
    {
        const hsvColor = getLayersColorHSV;
        const padding = calcLayerPadding;

        auto bottomLayerStyle = getBottomLayerStyle(hsvColor);
        auto bottomLayer = createLayer(bottomLayerStyle, padding, padding * 4);
        window.showingTasks ~= (dt) { bottomLayer.dispose; };

        auto middleLayerStyle = getMiddleLayerStyle(hsvColor);
        auto middleLayer = createLayer(middleLayerStyle, padding, padding * 2);
        window.showingTasks ~= (dt) { middleLayer.dispose; };

        auto topLayerStyle = getTopLayerStyle(hsvColor);
        auto topLayer = createLayer(topLayerStyle, padding, padding);
        window.showingTasks ~= (dt) { topLayer.dispose; };

        auto ledTexture = composeLayers([bottomLayer, middleLayer, topLayer]);
        return ledTexture;
    }

    override void create()
    {
        super.create;

        // auto hsvColor = colorHue.toHSV;
        // hsvColor.saturation = 1;
        // hsvColor.value = 1;

        // auto bottomHsvColor = hsvColor;
        // bottomHsvColor.value = 0.8;
        // bottomHsvColor.saturation = 0.7;
        // auto middleHsvColor = hsvColor;
        // auto topHsvColor = hsvColor;
        // topHsvColor.saturation = 0.1;

        // auto style = createDefaultStyle;
        // style.isFill = true;
        // style.color = bottomLayerColor;

        // const padding = calcLayerPadding;

        // auto bottomLayer = newLayer(style, padding * 4);
        // window.showingTasks ~= (dt) { bottomLayer.dispose; };

        // auto style2 = createDefaultStyle;
        // style2.isFill = true;
        // style2.color = middleLayerColor;

        // auto middleLayer = newLayer(style2, padding * 2);
        // window.showingTasks ~= (dt) { middleLayer.dispose; };

        // auto style3 = createDefaultStyle;
        // style3.isFill = true;
        // style3.color = topLayerColor;

        // auto topLayer = newLayer(style3, padding);

    }
}
