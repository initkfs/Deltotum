module api.dm.addon.gui.controls.indicators.leds.led_icon;

import api.dm.addon.gui.controls.indicators.leds.led_base : LedBase;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.gui.controls.containers.vbox : VBox;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.colors.hsva : HSVA;
import api.math.insets : Insets;
import IconName = api.dm.gui.themes.icons.icon_name;
import api.dm.kit.sprites2d.images.image : Image;

import std.conv : to;

import ColorProcessor = api.dm.kit.graphics.colors.processing.color_processor;

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

    override protected Sprite2d newLayerShape(GraphicStyle style, double layerInnerPadding, double blurSize)
    {
        const size_t iconSize = cast(size_t)(width);
        const mustBeIconData = theme.iconData(iconName);
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

    override Sprite2d createLedLayer()
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

        // auto hsvColor = colorHue.toHSVA;
        // hsvColor.saturation = 1;
        // hsvColor.value = 1;

        // auto bottomHsvColor = hsvColor;
        // bottomHsvColor.value = 0.8;
        // bottomHsvColor.saturation = 0.7;
        // auto middleHsvColor = hsvColor;
        // auto topHsvColor = hsvColor;
        // topHsvColor.saturation = 0.1;

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
