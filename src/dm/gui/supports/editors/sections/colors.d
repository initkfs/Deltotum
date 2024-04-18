module dm.gui.supports.editors.sections.colors;

import dm.gui.controls.control : Control;
import dm.math.rect2d : Rect2d;
import dm.kit.sprites.layouts.flow_layout : FlowLayout;

import std.stdio;
import std.conv : to;

/**
 * Authors: initkfs
 */
class Colors : Control
{
    protected
    {
        FlowLayout flowLayout;
    }
    this()
    {
        flowLayout = new FlowLayout(2, 0);
        this.layout = flowLayout;
        flowLayout.isUseFlowWidth = true;
        layout.isAutoResize = true;
        isBackground = false;
    }

    override void initialize()
    {
        super.initialize;
        enablePadding;
    }

    override void create()
    {
        super.create;

        flowLayout.flowWidth = window.width;

        import dm.kit.graphics.colors.rgba : RGBA;
        import dm.kit.graphics.colors.palettes.material_palette : MaterialPalette;
        import std.traits : EnumMembers;
        import std.range : chunks;

        import dm.gui.containers.vbox : VBox;
        import dm.gui.containers.stack_box : StackBox;
        import dm.gui.containers.container : Container;
        import dm.gui.controls.texts.text : Text;
        import dm.kit.assets.fonts.font_size : FontSize;
        import dm.kit.graphics.styles.graphic_style : GraphicStyle;

        auto colorSets = [EnumMembers!MaterialPalette].chunks(14);
        foreach (colorSet; colorSets)
        {
            auto setContainer = new VBox;
            addCreate(setContainer);

            foreach (c; colorSet)
                (color) {
                auto colorContainer = new VBox;
                colorContainer.isAlignX = true;
                colorContainer.isBackground = false;
                colorContainer.width = 65;
                colorContainer.height = 30;

                setContainer.addCreate(colorContainer);

                import dm.kit.sprites.textures.vectors.shapes.vregular_polygon : VRegularPolygon;

                auto colorHex = cast(string) color;
                auto newColor = RGBA.web(colorHex);

                colorContainer.onPointerDown ~= (ref e) {
                    input.clipboard.setText(colorHex);
                };

                auto style = new GraphicStyle(1, newColor, true, newColor);

                auto colorText = new Text();
                colorText.userStyle = style;
                colorText.fontSize = FontSize.small;
                colorText.text = (cast(string) color).to!dstring;
                colorContainer.addCreate(colorText);

                auto shape = new VRegularPolygon(colorContainer.width, colorContainer.height, *style, 0);
                colorContainer.addCreate(shape);
            }(c);
        }
    }
}
