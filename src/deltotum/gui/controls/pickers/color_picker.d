module deltotum.gui.controls.pickers.color_picker;

import deltotum.gui.controls.control : Control;
import deltotum.kit.sprites.layouts.layout : Layout;
import deltotum.math.geom.insets : Insets;
import deltotum.kit.sprites.textures.texture : Texture;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.gui.controls.texts.text : Text;
import deltotum.gui.controls.buttons.button : Button;
import deltotum.kit.graphics.shapes.circle : Circle;
import deltotum.kit.graphics.colors.rgba : RGBA;
import deltotum.kit.graphics.colors.palettes.material_design_palette : MaterialDesignPalette;
import deltotum.gui.containers.flow_box : FlowBox;

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
        FlowBox colorChooser;
    }

    this()
    {
        import deltotum.kit.sprites.layouts.hlayout : HLayout;

        auto layout = new HLayout;
        layout.isAutoResize = true;
        layout.isAlignY = true;
        this.layout = layout;

        isBorder = true;
    }

    override void create()
    {
        super.create;

        RGBA startColor = RGBA.white;

        colorIndicator = new Circle(10, GraphicStyle(1, startColor, true, startColor));
        addCreate(colorIndicator);

        colorText = new Text(startColor.toWebHex);
        colorText.setGrow;
        addCreate(colorText);

        colorShowChooser = new Button("▼", 10, 10);
        colorShowChooser.setGrow;
        addCreate(colorShowChooser);

        colorShowChooser.onAction = (ref e) { toggleChooser; };

        colorChooser = new FlowBox;
        colorChooser.isLayoutManaged = false;
        addCreate(colorChooser);
        colorChooser.width = 400;
        colorChooser.isVisible = false;
        import deltotum.kit.graphics.shapes.rectangle : Rectangle;
        import std.traits : EnumMembers;

        foreach (i, hexColor; EnumMembers!MaterialDesignPalette)
        {
            RGBA rgba = RGBA.web(hexColor);
            const size = 15;
            auto rect = new Rectangle(size, size);
            rect.onMouseEntered = (ref e) {
                rect.style.lineColor = RGBA.white;
            };
            rect.onMouseExited = (ref e) {
                rect.style.lineColor = rgba;
            };
            rect.onMouseDown = (ref e) {
                colorIndicator.style.fillColor = rgba;
                colorIndicator.style.lineColor = rgba;
                colorText.text = hexColor;
                toggleChooser;
            };
            rect.style = GraphicStyle(1, rgba, true, rgba);
            colorChooser.addCreate(rect);
        }

    }

    void toggleChooser()
    {
        const b = bounds;
        colorChooser.x = b.x;
        colorChooser.y = b.bottom;

        colorChooser.isVisible = !colorChooser.isVisible;
    }

}
