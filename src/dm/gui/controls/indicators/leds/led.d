module dm.gui.controls.indicators.leds.led;

import dm.kit.sprites.sprite : Sprite;
import dm.gui.controls.control : Control;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;
import dm.gui.containers.vbox : VBox;
import dm.gui.containers.hbox : HBox;
import dm.kit.graphics.colors.rgba : RGBA;

/**
 * Authors: initkfs
 */
class Led : Control
{

    this(double width = 35, double height = 35)
    {
        this.width = width;
        this.height = height;

        import dm.kit.sprites.layouts.center_layout : CenterLayout;

        layout = new CenterLayout;
    }

    override void create()
    {
        super.create;

        import dm.kit.sprites.textures.vectors.vcircle : VCircle;
        import ColorProcessor = dm.kit.graphics.colors.processing.color_processor;
        import dm.kit.sprites.textures.texture : Texture;

        auto style = createDefaultStyle(width, height);
        style.isFill = true;
        style.color = RGBA.web("#12E104");

        enum padding = 3;
        auto shape = new VCircle(width / 2 - padding, style, width, height);
        shape.onSurfaceIsContinue = (surf) {

            RGBA[][] buff = surfaceToBuffer(surf);
            RGBA[][] gaussBuff = ColorProcessor.boxblur(buff, padding * 2);

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

        addCreate(shape);

        auto style2 = createDefaultStyle(width, height);
        style2.isFill = true;
        style2.color = RGBA.web("#68FD5E");

        auto shape2 = new VCircle(width / 2 - padding * 2, style2, width, height);
        shape2.onSurfaceIsContinue = (surf) {

            RGBA[][] buff = surfaceToBuffer(surf);
            RGBA[][] gaussBuff = ColorProcessor.boxblur(buff, padding * 4);

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
        build(shape2);
        shape2.initialize;
        shape2.create;

        style.color = RGBA.white;

        auto style3 = createDefaultStyle(width, height);
        style3.isFill = true;
        style3.color = RGBA.web("#CEFFCB");

        auto shape3 = new VCircle(width / 2 - padding * 3, style3, width, height);
        shape3.onSurfaceIsContinue = (surf) {

            RGBA[][] buff = surfaceToBuffer(surf);
            RGBA[][] gaussBuff = ColorProcessor.boxblur(buff, padding * 4);

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
        build(shape3);
        shape3.initialize;
        shape3.create;

        auto texture = new Texture(width, height);
        build(texture);
        texture.createTargetRGBA32;
        texture.setRendererTarget;

        //shape.opacity = 0.7;
        //shape3.opacity = 0.5;

        import dm.com.graphics.com_blend_mode : ComBlendMode;

        texture.blendMode = ComBlendMode.blend;

        shape.draw;
        shape2.draw;
        shape3.draw;

        texture.resetRendererTarget;

        addCreate(texture);

        shape.isVisible = false;

    }
}
