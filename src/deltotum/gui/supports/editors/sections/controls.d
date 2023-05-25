module deltotum.gui.supports.editors.sections.controls;

import deltotum.gui.controls.control : Control;
import deltotum.kit.sprites.sprite : Sprite;
import deltotum.kit.graphics.colors.rgba : RGBA;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 */
class Controls : Control
{
    this()
    {
        id = "deltotum_gui_editor_section_controls";

        import deltotum.kit.sprites.layouts.vertical_layout : VerticalLayout;

        layout = new VerticalLayout(5);
        layout.isAutoResize = true;
        isBackground = false;
    }

    override void create()
    {
        super.create;

        // auto iconsContainer = new HBox;
        // iconsContainer.isBackground = false;

        // import deltotum.kit.sprites.images.image : Image;

        // auto image1 = new Image();
        // build(image1);
        // image1.loadRaw(graphics.theme.iconData("rainy-outline"), 64, 64);
        // image1.setColor(graphics.theme.colorAccent);

        // auto image2 = new Image();
        // build(image2);
        // image2.loadRaw(graphics.theme.iconData("thunderstorm-outline"), 64, 64);
        // image2.setColor(graphics.theme.colorAccent);

        // auto image3 = new Image();
        // build(image3);
        // image3.loadRaw(graphics.theme.iconData("sunny-outline"), 64, 64);
        // image3.setColor(graphics.theme.colorAccent);

        // auto image4 = new Image();
        // build(image4);
        // image4.loadRaw(graphics.theme.iconData("cloudy-night-outline"), 64, 64);
        // image4.setColor(graphics.theme.colorAccent);

        // auto image5 = new Image();
        // build(image5);
        // image5.loadRaw(graphics.theme.iconData("flash-outline"), 64, 64);
        // image5.setColor(graphics.theme.colorAccent);

        // addCreate(iconsContainer);
        // iconsContainer.addCreate([image1, image2, image3, image4, image5]);

    }

}
