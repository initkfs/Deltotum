module dm.gui.supports.editors.sections.images;

import dm.gui.controls.control : Control;
import dm.kit.sprites.sprite : Sprite;
import dm.kit.graphics.colors.rgba : RGBA;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;
import dm.kit.sprites.images.image : Image;
import dm.kit.sprites.images.image : Image;
import std.string : toStringz;

import ImageProcessor = dm.kit.sprites.images.processing.image_processor;

import Math = dm.math;

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

        import dm.kit.sprites.layouts.vlayout : VLayout;

        layout = new VLayout(5);
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

    Sprite createImageInfo(string name, Sprite image)
    {
        import dm.gui.containers.vbox : VBox;
        import dm.gui.controls.texts.text : Text;

        auto container = new VBox;
        buildCreate(container);
        container.enableInsets;

        auto label = new Text;
        label.text = name;
        container.addCreate(label);

        container.addCreate(image);

        return container;
    }

    override void create()
    {
        super.create;

        import dm.gui.containers.container : Container;
        import dm.gui.containers.hbox : HBox;
        import dm.gui.containers.vbox : VBox;
        import dm.gui.containers.container : Container;
        import dm.gui.containers.stack_box : StackBox;
        import dm.math.geom.insets : Insets;

        auto container = new HBox;
        addCreate(container);
        container.enableInsets;

        auto original = new Image;
        build(original);

        static RGBA[][] colorBuff = new RGBA[][](imageSize, imageSize);

        original.colorProcessor = (x, y, color) {
            colorBuff[y][x] = color;
            return color;
        };

        original.loadRaw(originalImage);
        container.addCreate(createImageInfo("Original", original));

        const size_t imageWidth = cast(size_t) original.width;
        const size_t imageHeight = cast(size_t) original.height;

        auto hist = new Image(imageWidth, imageHeight);
        build(hist);
        hist.load(ImageProcessor.histogram(colorBuff));
        container.addCreate(createImageInfo("Histogram", hist));

        auto grayscale = new Image(imageWidth, imageHeight);
        build(grayscale);
        grayscale.colorProcessor = (x, y, color) {
            return ImageProcessor.grayscale(color);
        };
        grayscale.load(colorBuff);
        container.addCreate(createImageInfo("Grayscale", grayscale));

        auto grayscaleThreshold = new Image(imageWidth, imageHeight);
        build(grayscaleThreshold);
        grayscaleThreshold.colorProcessor = (x, y, color) {
            return ImageProcessor.grayscale(color, 200);
        };
        grayscaleThreshold.load(colorBuff);
        container.addCreate(createImageInfo("Grayscale 200", grayscaleThreshold));

        auto negative = new Image(imageWidth, imageHeight);
        build(negative);
        negative.colorProcessor = (x, y, color) {
            return ImageProcessor.negative(color);
        };
        negative.load(colorBuff);
        container.addCreate(createImageInfo("Negative", negative));

        auto solar1 = new Image(imageWidth, imageHeight);
        build(solar1);
        solar1.colorProcessor = (x, y, color) {
            return ImageProcessor.solarization(color, 120);
        };
        solar1.load(colorBuff);
        container.addCreate(createImageInfo("Solar 120", solar1));

        auto sepia = new Image(imageWidth, imageHeight);
        build(sepia);
        sepia.colorProcessor = (x, y, color) {
            return ImageProcessor.sepia(color);
        };
        sepia.load(colorBuff);
        container.addCreate(createImageInfo("Sepia", sepia));

        auto poster = new Image(imageWidth, imageHeight);
        build(poster);
        poster.colorProcessor = (x, y, color) {
            return ImageProcessor.posterize(color, [
                    RGBA.red,
                    RGBA.blue,
                    RGBA.green
                ], 160);
        };
        poster.load(colorBuff);
        container.addCreate(createImageInfo("Poster", poster));

        auto blend = new Image(imageWidth, imageHeight);
        build(blend);
        blend.load(ImageProcessor.blend(colorBuff, RGBA.blue, ImageProcessor.BlendMode.overlay));
        container.addCreate(createImageInfo("Blend", blend));

        auto container2 = new HBox;
        addCreate(container2);

        auto br1 = new Image(imageWidth, imageHeight);
        build(br1);
        br1.colorProcessor = (x, y, color) { color.brightness(2); return color; };
        br1.load(colorBuff);
        container2.addCreate(createImageInfo("Bright x2", br1));

        auto gamma1 = new Image(imageWidth, imageHeight);
        build(gamma1);
        gamma1.colorProcessor = (x, y, color) { color.gamma(0.2); return color; };
        gamma1.load(colorBuff);
        container2.addCreate(createImageInfo("Gamma 0.2", gamma1));

        auto gamma2 = new Image(imageWidth, imageHeight);
        build(gamma2);
        gamma2.colorProcessor = (x, y, color) { color.gamma(2.0); return color; };
        gamma2.load(colorBuff);
        container2.addCreate(createImageInfo("Gamma 2.0", gamma2));

        auto contrast1 = new Image(imageWidth, imageHeight);
        build(contrast1);
        contrast1.colorProcessor = (x, y, color) {
            color.contrast(-50);
            return color;
        };
        contrast1.load(colorBuff);
        container2.addCreate(createImageInfo("Contrast -50", contrast1));

        auto contrast2 = new Image(imageWidth, imageHeight);
        build(contrast2);
        contrast2.colorProcessor = (x, y, color) {
            color.contrast(80);
            return color;
        };
        contrast2.load(colorBuff);
        container2.addCreate(createImageInfo("Contrast +80", contrast2));

        auto flop = new Image(imageWidth, imageHeight);
        build(flop);
        flop.load(ImageProcessor.flop(colorBuff));
        container2.addCreate(createImageInfo("Flop (X)", flop));

        auto flip = new Image(imageWidth, imageHeight);
        build(flip);
        flip.load(ImageProcessor.flip(colorBuff));
        container2.addCreate(createImageInfo("Flip (Y)", flip));

        auto mirror = new Image(imageWidth, imageHeight);
        build(mirror);
        mirror.load(ImageProcessor.mirror(colorBuff));
        container2.addCreate(createImageInfo("Mirror", mirror));

        auto rotate45 = new Image(imageWidth, imageHeight);
        build(rotate45);
        rotate45.load(ImageProcessor.rotate(colorBuff, 45));
        container2.addCreate(createImageInfo("Rotate 45", rotate45));

        auto bilinear = new Image(imageWidth / 2, imageHeight / 2);
        build(bilinear);
        bilinear.load(ImageProcessor.resizeBilinear(colorBuff, imageWidth / 2, imageHeight / 2));
        container2.addCreate(createImageInfo("Bilinear", bilinear));

        import dm.math.shapes.rect2d : Rect2d;

        auto crop = new Image(50, 50);
        build(crop);
        crop.load(ImageProcessor.crop(colorBuff, Rect2d(10, 10, 50, 50)));
        container2.addCreate(createImageInfo("Crop", crop));

        auto container3 = new HBox;
        addCreate(container3);

        auto highpass = new Image(imageWidth, imageHeight);
        build(highpass);
        highpass.load(ImageProcessor.highpass(colorBuff));
        container3.addCreate(createImageInfo("Highpass", highpass));

        auto lowpass = new Image(imageWidth, imageHeight);
        build(lowpass);
        lowpass.load(ImageProcessor.lowpass(colorBuff));
        container3.addCreate(createImageInfo("Lowpass", lowpass));

        auto gaussian = new Image(imageWidth, imageHeight);
        build(gaussian);
        gaussian.load(ImageProcessor.gaussian3x3(colorBuff));
        container3.addCreate(createImageInfo("Gauss 3x3", gaussian));

        auto sobel = new Image(imageWidth, imageHeight);
        build(sobel);
        sobel.load(ImageProcessor.sobel(colorBuff));
        container3.addCreate(createImageInfo("Sobel", sobel));

        auto emboss = new Image(imageWidth, imageHeight);
        build(emboss);
        emboss.load(ImageProcessor.emboss(colorBuff));
        container3.addCreate(createImageInfo("Emboss", emboss));

    }

}
