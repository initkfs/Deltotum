module api.dm.gui.supports.editors.sections.images;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites2d.images.image : Image;
import api.dm.kit.sprites2d.images.image : Image;
import std.string : toStringz;

import ColorProcessor = api.dm.kit.graphics.colors.processings;

import Math = api.dm.math;

import std.stdio;

/**
 * Authors: initkfs
 */
class Images : Control
{
    private
    {
        const originalImage = import("resources/Lenna.png");

        GraphicStyle shapeStyle = GraphicStyle.simple;

        enum imageSize = 100;
    }

    this()
    {
        id = "deltotum_gui_editor_section_images";

        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout;
        layout.isAutoResize = true;
        isBackground = false;
        layout.isAlignY = false;
    }

    override void initialize()
    {
        super.initialize;
        enablePadding;
    }

    T configureControl(T)(T sprite)
    {
        static if (is(T : Control))
        {
            sprite.isBorder = true;
        }
        return sprite;
    }

    Sprite2d createImageInfo(string name, Sprite2d image)
    {
        import api.dm.gui.controls.containers.vbox : VBox;
        import api.dm.gui.controls.texts.text : Text;

        auto container = new VBox;
        container.isAlignX = true;
        buildInitCreate(container);
        container.enablePadding;

        auto label = new Text(name);
        container.addCreate(label);

        container.addCreate(image);

        return container;
    }

    override void create()
    {
        super.create;

        import api.dm.gui.controls.containers.container : Container;
        import api.dm.gui.controls.containers.hbox : HBox;
        import api.dm.gui.controls.containers.vbox : VBox;
        import api.dm.gui.controls.containers.container : Container;
        import api.dm.gui.controls.containers.center_box : CenterBox;
        import api.math.pos2.insets : Insets;

        auto container = new HBox;
        addCreate(container);
        container.enablePadding;

        auto original = new Image;
        build(original);

        static RGBA[][] colorBuff = new RGBA[][](imageSize, imageSize);

        original.onColor = (x, y, color) {
            colorBuff[y][x] = color;
            return color;
        };

        original.loadRaw(originalImage);
        container.addCreate(createImageInfo("Original", original));

        const size_t imageWidth = cast(size_t) original.width;
        const size_t imageHeight = cast(size_t) original.height;

        auto hist = new Image(imageWidth, imageHeight);
        build(hist);
        hist.load(ColorProcessor.histogram(colorBuff));
        container.addCreate(createImageInfo("Histogram", hist));

        auto grayscale = new Image(imageWidth, imageHeight);
        build(grayscale);
        grayscale.onColor = (x, y, color) {
            return ColorProcessor.grayscale(color);
        };
        grayscale.load(colorBuff);
        container.addCreate(createImageInfo("Grayscale", grayscale));

        auto grayscaleThreshold = new Image(imageWidth, imageHeight);
        build(grayscaleThreshold);
        grayscaleThreshold.onColor = (x, y, color) {
            return ColorProcessor.grayscale(color, 200);
        };
        grayscaleThreshold.load(colorBuff);
        container.addCreate(createImageInfo("Grayscale 200", grayscaleThreshold));

        auto negative = new Image(imageWidth, imageHeight);
        build(negative);
        negative.onColor = (x, y, color) {
            return ColorProcessor.negative(color);
        };
        negative.load(colorBuff);
        container.addCreate(createImageInfo("Negative", negative));

        auto solar1 = new Image(imageWidth, imageHeight);
        build(solar1);
        solar1.onColor = (x, y, color) {
            return ColorProcessor.solarization(color, 120);
        };
        solar1.load(colorBuff);
        container.addCreate(createImageInfo("Solar 120", solar1));

        auto sepia = new Image(imageWidth, imageHeight);
        build(sepia);
        sepia.onColor = (x, y, color) {
            return ColorProcessor.sepia(color);
        };
        sepia.load(colorBuff);
        container.addCreate(createImageInfo("Sepia", sepia));

        auto poster = new Image(imageWidth, imageHeight);
        build(poster);
        poster.onColor = (x, y, color) {
            return ColorProcessor.posterize(color, [
                    RGBA.red,
                    RGBA.blue,
                    RGBA.green
                ], 160);
        };
        poster.load(colorBuff);
        container.addCreate(createImageInfo("Poster", poster));

        auto blend = new Image(imageWidth, imageHeight);
        build(blend);
        blend.load(ColorProcessor.blend(colorBuff, RGBA.blue, ColorProcessor.BlendMode.overlay));
        container.addCreate(createImageInfo("Blend", blend));

        auto container2 = new HBox;
        addCreate(container2);

        auto br1 = new Image(imageWidth, imageHeight);
        build(br1);
        br1.onColor = (x, y, color) { color.brightness(2); return color; };
        br1.load(colorBuff);
        container2.addCreate(createImageInfo("Bright x2", br1));

        auto gamma1 = new Image(imageWidth, imageHeight);
        build(gamma1);
        gamma1.onColor = (x, y, color) { color.gamma(0.2); return color; };
        gamma1.load(colorBuff);
        container2.addCreate(createImageInfo("Gamma 0.2", gamma1));

        auto gamma2 = new Image(imageWidth, imageHeight);
        build(gamma2);
        gamma2.onColor = (x, y, color) { color.gamma(2.0); return color; };
        gamma2.load(colorBuff);
        container2.addCreate(createImageInfo("Gamma 2.0", gamma2));

        auto contrast1 = new Image(imageWidth, imageHeight);
        build(contrast1);
        contrast1.onColor = (x, y, color) {
            color.contrast(-50);
            return color;
        };
        contrast1.load(colorBuff);
        container2.addCreate(createImageInfo("Contrast -50", contrast1));

        auto contrast2 = new Image(imageWidth, imageHeight);
        build(contrast2);
        contrast2.onColor = (x, y, color) {
            color.contrast(80);
            return color;
        };
        contrast2.load(colorBuff);
        container2.addCreate(createImageInfo("Contrast +80", contrast2));

        auto flop = new Image(imageWidth, imageHeight);
        build(flop);
        flop.load(ColorProcessor.flop(colorBuff));
        container2.addCreate(createImageInfo("Flop (X)", flop));

        auto flip = new Image(imageWidth, imageHeight);
        build(flip);
        flip.load(ColorProcessor.flip(colorBuff));
        container2.addCreate(createImageInfo("Flip (Y)", flip));

        auto mirror = new Image(imageWidth, imageHeight);
        build(mirror);
        mirror.load(ColorProcessor.mirror(colorBuff));
        container2.addCreate(createImageInfo("Mirror", mirror));

        auto rotate45 = new Image(imageWidth, imageHeight);
        build(rotate45);
        rotate45.load(ColorProcessor.rotate(colorBuff, 45));
        container2.addCreate(createImageInfo("Rotate 45", rotate45));

        auto bilinear = new Image(imageWidth / 2, imageHeight / 2);
        build(bilinear);
        bilinear.load(ColorProcessor.bilinear(colorBuff, imageWidth / 2, imageHeight / 2));
        container2.addCreate(createImageInfo("Bilinear", bilinear));

        import api.math.geom2.rect2 : Rect2f;

        auto crop = new Image(50, 50);
        build(crop);
        crop.load(ColorProcessor.crop(colorBuff, Rect2f(10, 10, 50, 50)));
        container2.addCreate(createImageInfo("Crop", crop));

        auto container3 = new HBox;
        addCreate(container3);

        auto highpass = new Image(imageWidth, imageHeight);
        build(highpass);
        highpass.load(ColorProcessor.highpass(colorBuff));
        container3.addCreate(createImageInfo("Highpass", highpass));

        auto lowpass = new Image(imageWidth, imageHeight);
        build(lowpass);
        lowpass.load(ColorProcessor.lowpass(colorBuff));
        container3.addCreate(createImageInfo("Lowpass", lowpass));

        auto gaussian = new Image(imageWidth, imageHeight);
        build(gaussian);
        gaussian.load(ColorProcessor.gaussian3x3(colorBuff));
        container3.addCreate(createImageInfo("Gauss 3x3", gaussian));

        auto sobel = new Image(imageWidth, imageHeight);
        build(sobel);
        sobel.load(ColorProcessor.sobel(colorBuff));
        container3.addCreate(createImageInfo("Sobel", sobel));

        auto emboss = new Image(imageWidth, imageHeight);
        build(emboss);
        emboss.load(ColorProcessor.emboss(colorBuff));
        container3.addCreate(createImageInfo("Emboss", emboss));

    }

}
