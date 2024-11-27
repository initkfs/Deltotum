module api.dm.gui.controls.pickers.color_picker;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.layouts.layout : Layout;
import api.math.insets : Insets;
import api.dm.kit.sprites.textures.texture : Texture;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.buttons.button : Button;
import api.dm.kit.sprites.shapes.circle : Circle;
import api.dm.kit.graphics.colors.rgba : RGBA;
import MaterialPalette = api.dm.kit.graphics.colors.palettes.material_palette;
import api.dm.gui.containers.vbox : VBox;
import api.dm.gui.containers.hbox : HBox;

/**
 * Authors: initkfs
 */
class ColorPicker : Control
{
    protected
    {
        Circle colorIndicator;
        Text colorText;
        Button colorShowChooser;
        VBox colorChooser;
    }

    this()
    {
        import api.dm.kit.sprites.layouts.hlayout : HLayout;

        auto layout = new HLayout(5);
        layout.isAutoResize = true;
        layout.isAlignY = true;
        this.layout = layout;

        isBorder = true;
    }

    override void create()
    {
        super.create;

        enableInsets;

        RGBA startColor = RGBA.white;

        colorIndicator = new Circle(10, GraphicStyle(1, startColor, true, startColor));
        addCreate(colorIndicator);

        colorText = new Text(startColor.toWebHex);
        addCreate(colorText);

        colorShowChooser = new Button("▼", 10, 10);
        colorShowChooser.setGrow;
        addCreate(colorShowChooser);

        colorShowChooser.onAction ~= (ref e) { toggleChooser; };

        colorChooser = new VBox(0);
        colorChooser.isLayoutManaged = false;

        addCreate(colorChooser);

        colorChooser.isVisible = false;
        import api.dm.kit.sprites.shapes.rectangle : Rectangle;

        enum colorContainerSize = 15;
        enum colorTonesCount = 14;

        HBox colorContainer;

        // foreach (i, hexColor; EnumMembers!MaterialPalette)
        // {
        //     if (i % colorTonesCount == 0)
        //     {
        //         colorContainer = new HBox(0);
        //         colorContainer.id = "color_picker_tone_container";
        //         //TODO remove paddings from initialization;
        //         // colorContainer.padding = Insets(0);
        //         colorChooser.addCreate(colorContainer);
        //         colorContainer.padding = Insets(0);
        //     }

        //     RGBA rgba = RGBA.web(hexColor);
        //     const size = colorContainerSize;
        //     auto rect = new Rectangle(size, size);
        //     rect.onPointerEntered ~= (ref e) { rect.style.lineColor = RGBA.white; };
        //     rect.onPointerExited ~= (ref e) { rect.style.lineColor = rgba; };
        //     rect.onPointerDown ~= (ref e) {
        //         colorIndicator.style.fillColor = rgba;
        //         colorIndicator.style.lineColor = rgba;
        //         colorText.text = hexColor;
        //         toggleChooser;
        //     };
        //     rect.style = GraphicStyle(1, rgba, true, rgba);
        //     colorContainer.addCreate(rect);
        // }

    }

    void toggleChooser()
    {
        const b = bounds;
        colorChooser.x = b.x;
        colorChooser.y = b.bottom;

        colorChooser.isVisible = !colorChooser.isVisible;
    }

}
