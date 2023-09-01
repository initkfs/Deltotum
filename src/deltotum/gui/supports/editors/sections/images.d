module deltotum.gui.supports.editors.sections.images;

import deltotum.gui.controls.control : Control;
import deltotum.kit.sprites.sprite : Sprite;
import deltotum.kit.graphics.colors.rgba : RGBA;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.kit.sprites.images.image : Image;
import deltotum.kit.sprites.images.processing.image_processor : ImageProcessor;
import deltotum.kit.sprites.images.texture_image : TextureImage;
import std.string : toStringz;

import Math = deltotum.math;

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

        ImageProcessor imageProcessor;

        enum imageSize = 100;
    }

    this()
    {
        id = "deltotum_gui_editor_section_images";

        import deltotum.kit.sprites.layouts.vlayout : VLayout;

        layout = new VLayout(5);
        layout.isAutoResize = true;
        isBackground = false;
        layout.isAlignY = false;

        imageProcessor = new ImageProcessor;
    }

    override void initialize()
    {
        super.initialize;
        enablePadding;
    }

    T configureControl(T)(T sprite)
    {
        if (is(T : Control))
        {
            sprite.isBorder = true;
        }
        return sprite;
    }

    Sprite createImageInfo(string name, Sprite image)
    {
        import deltotum.gui.containers.vbox : VBox;
        import deltotum.gui.controls.texts.text : Text;

        auto container = new VBox;
        buildCreate(container);

        auto label = new Text;
        label.text = name;
        container.addCreate(label);

        container.addCreate(image);

        return container;
    }

    override void create()
    {
        super.create;

        import deltotum.gui.containers.container : Container;
        import deltotum.gui.containers.hbox : HBox;
        import deltotum.gui.containers.vbox : VBox;
        import deltotum.gui.containers.container : Container;
        import deltotum.gui.containers.stack_box : StackBox;
        import deltotum.math.geom.insets : Insets;

        auto container = new HBox;
        addCreate(container);

        auto original = new Image;
        build(original);

        static RGBA[][] colorBuff = new RGBA[][](imageSize, imageSize);

        original.colorProcessor = (pixelData) {
            colorBuff[pixelData.y][pixelData.x] = pixelData.getColor;
        };

        original.loadRaw(originalImage);
        container.addCreate(createImageInfo("Original", original));

        const size_t imageWidth = cast(size_t) original.width;
        const size_t imageHeight = cast(size_t) original.height;

        auto hist = new Image(imageWidth, imageHeight);
        build(hist);
        hist.load(imageProcessor.histogram(colorBuff));
        container.addCreate(createImageInfo("Histogram", hist));

        auto grayscale = new Image(imageWidth, imageHeight);
        build(grayscale);
        grayscale.colorProcessor = (pixel) {
            pixel.setColor(imageProcessor.grayscale(pixel.getColor));
        };
        grayscale.load(colorBuff);
        container.addCreate(createImageInfo("Grayscale", grayscale));

        auto grayscaleThreshold = new Image(imageWidth, imageHeight);
        build(grayscaleThreshold);
        grayscaleThreshold.colorProcessor = (pixel) {
            pixel.setColor(imageProcessor.grayscale(pixel.getColor, 200));
        };
        grayscaleThreshold.load(colorBuff);
        container.addCreate(createImageInfo("Grayscale 200", grayscaleThreshold));

        auto negative = new Image(imageWidth, imageHeight);
        build(negative);
        negative.colorProcessor = (pixel) {
            pixel.setColor(imageProcessor.negative(pixel.getColor));
        };
        negative.load(colorBuff);
        container.addCreate(createImageInfo("Negative", negative));

        auto solar1 = new Image(imageWidth, imageHeight);
        build(solar1);
        solar1.colorProcessor = (pixel) {
            pixel.setColor(imageProcessor.solarization(pixel.getColor, 120));
        };
        solar1.load(colorBuff);
        container.addCreate(createImageInfo("Solar 120", solar1));

        auto sepia = new Image(imageWidth, imageHeight);
        build(sepia);
        sepia.colorProcessor = (pixel) {
            pixel.setColor(imageProcessor.sepia(pixel.getColor));
        };
        sepia.load(colorBuff);
        container.addCreate(createImageInfo("Sepia", sepia));

        auto poster = new Image(imageWidth, imageHeight);
        build(poster);
        poster.colorProcessor = (pixel) {
            pixel.setColor(imageProcessor.posterize(pixel.getColor, [
                        RGBA.red,
                        RGBA.blue,
                        RGBA.green
                    ], 160));
        };
        poster.load(colorBuff);
        container.addCreate(createImageInfo("Poster", poster));

        import deltotum.kit.sprites.images.processing.image_processor : BlendMode;

        auto blend = new Image(imageWidth, imageHeight);
        build(blend);
        blend.load(imageProcessor.blend(colorBuff, RGBA.blue, BlendMode.overlay));
        container.addCreate(createImageInfo("Blend", blend));

        auto container2 = new HBox;
        addCreate(container2);

        auto br1 = new Image(imageWidth, imageHeight);
        build(br1);
        br1.colorProcessor = (pixel) {
            auto newColor = pixel.getColor;
            newColor.brightness(2);
            pixel.setColor(newColor);
        };
        br1.load(colorBuff);
        container2.addCreate(createImageInfo("Bright x2", br1));

        auto gamma1 = new Image(imageWidth, imageHeight);
        build(gamma1);
        gamma1.colorProcessor = (pixel) {
            auto newColor = pixel.getColor;
            newColor.gamma(0.2);
            pixel.setColor(newColor);
        };
        gamma1.load(colorBuff);
        container2.addCreate(createImageInfo("Gamma 0.2", gamma1));

        auto gamma2 = new Image(imageWidth, imageHeight);
        build(gamma2);
        gamma2.colorProcessor = (pixel) {
            auto newColor = pixel.getColor;
            newColor.gamma(2.0);
            pixel.setColor(newColor);
        };
        gamma2.load(colorBuff);
        container2.addCreate(createImageInfo("Gamma 2.0", gamma2));

        auto contrast1 = new Image(imageWidth, imageHeight);
        build(contrast1);
        contrast1.colorProcessor = (pixel) {
            auto newColor = pixel.getColor;
            newColor.contrast(-50);
            pixel.setColor(newColor);
        };
        contrast1.load(colorBuff);
        container2.addCreate(createImageInfo("Contrast -50", contrast1));

        auto contrast2 = new Image(imageWidth, imageHeight);
        build(contrast2);
        contrast2.colorProcessor = (pixel) {
            auto newColor = pixel.getColor;
            newColor.contrast(80);
            pixel.setColor(newColor);
        };
        contrast2.load(colorBuff);
        container2.addCreate(createImageInfo("Contrast +80", contrast2));

        auto flop = new Image(imageWidth, imageHeight);
        build(flop);
        flop.load(imageProcessor.flop(colorBuff));
        container2.addCreate(createImageInfo("Flop (X)", flop));

        auto flip = new Image(imageWidth, imageHeight);
        build(flip);
        flip.load(imageProcessor.flip(colorBuff));
        container2.addCreate(createImageInfo("Flip (Y)", flip));

        auto mirror = new Image(imageWidth, imageHeight);
        build(mirror);
        mirror.load(imageProcessor.mirror(colorBuff));
        container2.addCreate(createImageInfo("Mirror", mirror));

        auto rotate45 = new Image(imageWidth, imageHeight);
        build(rotate45);
        rotate45.load(imageProcessor.rotate(colorBuff, 45));
        container2.addCreate(createImageInfo("Rotate 45", rotate45));

        auto bilinear = new Image(imageWidth / 2, imageHeight / 2);
        build(bilinear);
        bilinear.load(imageProcessor.resizeBilinear(colorBuff, imageWidth / 2, imageHeight / 2));
        container2.addCreate(createImageInfo("Bilinear", bilinear));

        import deltotum.math.shapes.rect2d : Rect2d;

        auto crop = new Image(50, 50);
        build(crop);
        crop.load(imageProcessor.crop(colorBuff, Rect2d(10, 10, 50, 50)));
        container2.addCreate(createImageInfo("Crop", crop));

        auto container3 = new HBox;
        addCreate(container3);

        auto highpass = new Image(imageWidth, imageHeight);
        build(highpass);
        highpass.load(imageProcessor.highpass(colorBuff));
        container3.addCreate(createImageInfo("Highpass", highpass));

        auto lowpass = new Image(imageWidth, imageHeight);
        build(lowpass);
        lowpass.load(imageProcessor.lowpass(colorBuff));
        container3.addCreate(createImageInfo("Lowpass", lowpass));

        auto gaussian = new Image(imageWidth, imageHeight);
        build(gaussian);
        gaussian.load(imageProcessor.gaussian3x3(colorBuff));
        container3.addCreate(createImageInfo("Gauss 3x3", gaussian));

        auto sobel = new Image(imageWidth, imageHeight);
        build(sobel);
        sobel.load(imageProcessor.sobel(colorBuff));
        container3.addCreate(createImageInfo("Sobel", sobel));

        auto emboss = new Image(imageWidth, imageHeight);
        build(emboss);
        emboss.load(imageProcessor.emboss(colorBuff));
        container3.addCreate(createImageInfo("Emboss", emboss));

    }

}
