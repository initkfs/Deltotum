module api.dm.gui.supports.editors.sections.colors;

import api.dm.gui.controls.control : Control;
import api.math.geom2.rect2 : Rect2d;
import api.dm.kit.sprites.layouts.flow_layout : FlowLayout;

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

        import api.dm.kit.graphics.colors.rgba : RGBA;
        import api.dm.kit.graphics.colors.palettes.material_palette : MaterialPalette;
        import std.traits : EnumMembers;
        import std.range : chunks;

        import api.dm.gui.containers.vbox : VBox;
        import api.dm.gui.containers.stack_box : StackBox;
        import api.dm.gui.containers.container : Container;
        import api.dm.gui.controls.texts.text : Text;
        import api.dm.kit.assets.fonts.font_size : FontSize;
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

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

                import api.dm.kit.sprites.textures.vectors.shapes.vconvex_polygon : VConvexPolygon;

                auto colorHex = cast(string) color;
                auto newColor = RGBA.web(colorHex);

                colorContainer.onPointerDown ~= (ref e) {
                    input.clipboard.setText(colorHex);
                };

                auto style = GraphicStyle(1, newColor, true, newColor);

                auto colorText = new Text();
                //colorText.style = style;
                colorText.fontSize = FontSize.small;
                colorText.text = (cast(string) color).to!dstring;
                colorContainer.addCreate(colorText);

                auto shape = new VConvexPolygon(colorContainer.width, colorContainer.height, style, 0);
                colorContainer.addCreate(shape);
            }(c);
        }
    }
}
