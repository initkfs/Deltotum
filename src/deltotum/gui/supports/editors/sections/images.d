module deltotum.gui.supports.editors.sections.images;

import deltotum.gui.controls.control : Control;
import deltotum.kit.sprites.sprite : Sprite;
import deltotum.kit.graphics.colors.rgba : RGBA;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.kit.sprites.images.image : Image;
import deltotum.kit.sprites.images.processing.image_processor : ImageProcessor;
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

                enum shapeSize = 60;
                GraphicStyle shapeStyle = GraphicStyle.simple;

                ImageProcessor imageProcessor;
        }

        this()
        {
                id = "deltotum_gui_editor_section_images";

                import deltotum.kit.sprites.layouts.vertical_layout : VerticalLayout;

                layout = new VerticalLayout(5);
                layout.isAutoResize = true;
                isBackground = false;

                imageProcessor = new ImageProcessor;
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
                original.loadRaw(originalImage);
                container.addCreate(createImageInfo("Original", original));

                auto original2 = new Image;
                build(original2);
                original2.loadRaw(originalImage, -1, -1, (x, y, pixelData) {
                        const color = RGBA.green;
                        pixelData.setColor(color);
                });
                container.addCreate(createImageInfo("Original2", original2));

        }

}
