module dm.gui.controls.indicators.leds.led;

import dm.kit.sprites.sprite : Sprite;
import dm.gui.controls.control : Control;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;
import dm.kit.sprites.textures.texture : Texture;
import dm.gui.containers.vbox : VBox;
import dm.gui.containers.hbox : HBox;
import dm.kit.graphics.colors.rgba : RGBA;
import dm.kit.graphics.colors.hsv: HSV;
import dm.math.insets : Insets;

import ColorProcessor = dm.kit.graphics.colors.processing.color_processor;

/**
 * Authors: initkfs
 */
class Led : Control
{
    RGBA topLayerColor;
    RGBA middleLayerColor;
    RGBA bottomLayerColor;

    RGBA colorHue;

    this(RGBA colorHue = RGBA.red, double width = 50, double height = 50)
    {
        this.width = width;
        this.height = height;

        import dm.kit.sprites.layouts.center_layout : CenterLayout;

        layout = new CenterLayout;
        this.colorHue = colorHue;
    }

    double calcLayerPadding()
    {
        const padding = (width * 3) / 35;
        return padding;
    }

    protected Sprite newLayer(GraphicStyle style, double padding, double blurSize)
    {
        auto shape = createLayerShape(style, padding, blurSize);
        build(shape);
        shape.initialize;
        assert(shape.isInitialized);
        shape.create;
        assert(shape.isCreated);
        return shape;
    }

    protected Sprite createLayerShape(GraphicStyle style = GraphicStyle.simple, double padding, double blurSize)
    {
        import dm.kit.sprites.textures.vectors.vcircle : VCircle;

        auto hsvColor = colorHue.toHSV;
        hsvColor.saturation = 1;
        hsvColor.value = 1;

        auto bottomHsvColor = hsvColor;
        bottomHsvColor.value = 0.8;
        auto middleHsvColor = hsvColor;
        auto topHsvColor = hsvColor;
        topHsvColor.saturation = 0.1;

        bottomLayerColor = bottomHsvColor.toRGBA;
        middleLayerColor = middleHsvColor.toRGBA;
        topLayerColor = topHsvColor.toRGBA;

        import std.conv : to;

        auto shape = new VCircle(width / 2 - padding, style, width, height);
        shape.onSurfaceIsContinue = (surf) {
            RGBA[][] buff = surfaceToBuffer(surf);
            RGBA[][] gaussBuff = ColorProcessor.boxblur(buff, blurSize.to!size_t);

            surf.setPixels((x, y, color) {
                auto buffColor = gaussBuff[y][x];
                color[0] = buffColor.r;
                color[1] = buffColor.g;
                color[2] = buffColor.b;
                color[3] = buffColor.aByte;
                return true;
            });

            return true;
        };
        return shape;
    }

    override void create()
    {
        super.create;

        import dm.kit.sprites.textures.vectors.vcircle : VCircle;

        auto style = createDefaultStyle;
        style.isFill = true;
        style.color = bottomLayerColor;

        const padding = calcLayerPadding;

        auto bottomLayer = newLayer(style, padding, padding * 2);
        window.showingTasks ~= (dt)
        {
            bottomLayer.dispose;
        };

        auto style2 = createDefaultStyle;
        style2.isFill = true;
        style2.color = middleLayerColor;

        auto middleLayer = newLayer(style2, padding * 2, padding * 4);
        window.showingTasks ~= (dt)
        {
            middleLayer.dispose;
        };

        auto style3 = createDefaultStyle;
        style3.isFill = true;
        style3.color = topLayerColor;

        auto topLayer = newLayer(style3, padding * 3, padding * 4);
        window.showingTasks ~= (dt)
        {
            topLayer.dispose;
        };

        auto ledTexture = new Texture(width, height);
        build(ledTexture);
        ledTexture.createTargetRGBA32;

        import dm.com.graphics.com_blend_mode : ComBlendMode;

        ledTexture.blendMode = ComBlendMode.blend;

        ledTexture.setRendererTarget;
        bottomLayer.draw;
        middleLayer.draw;
        topLayer.draw;
        ledTexture.resetRendererTarget;

        addCreate(ledTexture);
    }
}
