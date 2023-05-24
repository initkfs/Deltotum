module deltotum.gui.supports.editors.controllers.curves_controller;

import deltotum.gui.controls.control: Control;
import deltotum.kit.sprites.sprite: Sprite;
import deltotum.kit.graphics.colors.rgba: RGBA;
import deltotum.kit.graphics.styles.graphic_style: GraphicStyle;

/**
 * Authors: initkfs
 */
class CurvesController : Control
{
    this()
    {
        id = "deltotum_gui_editor_layout_controller";

        import deltotum.kit.sprites.layouts.vertical_layout: VerticalLayout;

        layout = new VerticalLayout(5);
        layout.isAutoResize = true;
        isBackground = false;
    }

    override void create()
    {
        super.create;

        import deltotum.gui.containers.container : Container;
        import deltotum.gui.containers.hbox : HBox;
        import deltotum.gui.containers.vbox : VBox;
        import deltotum.gui.controls.texts.text_area : TextArea;
        import deltotum.gui.containers.container : Container;
        import deltotum.gui.containers.stack_box : StackBox;
        import deltotum.math.geometry.insets : Insets;

        auto shapeContainer = new HBox;
        addCreate(shapeContainer);

        import deltotum.kit.graphics.colors.palettes.material_design_palette : MaterialDesignPalette;
        import deltotum.kit.graphics.colors.rgba : RGBA;
        import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
    

        auto vectorContainers = new HBox;
        addCreate(vectorContainers);
        if (cap.isVectorGraphics)
        {
            import deltotum.math.geometry.curves.spirograph: Spirograph;
            import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
            import deltotum.kit.graphics.shapes.vectors.vpoints_shape : VPointsShape;
            import deltotum.math.vector2d: Vector2d;

            auto spirGen = new Spirograph;
            Vector2d[] points1 = spirGen.hypotrochoidPoints(30, 1, 27, 20);
            auto spir1 = new VPointsShape(points1, 150, 150, GraphicStyle(2, graphics.theme.colorAccent));

            Vector2d[] points2 = spirGen.hypotrochoidPoints(30, 1, 29, 8);
            auto spir2 = new VPointsShape(points2, 150, 150, GraphicStyle(2, graphics.theme.colorAccent));

            Vector2d[] points3 = spirGen.hypotrochoidPoints(30, 1, 15, 45);
            auto spir3 = new VPointsShape(points3, 150, 150, GraphicStyle(2, graphics.theme.colorAccent));

            Vector2d[] points4 = spirGen.hypotrochoidPoints(30, 1, 10, 10);
            auto spir4 = new VPointsShape(points4, 150, 150, GraphicStyle(2, graphics.theme.colorAccent));

            vectorContainers.addCreate([spir1, spir2, spir3, spir4]);

            import  deltotum.math.geometry.curves.lissajous: Lissajous;
            auto liss = new Lissajous;
            Vector2d[] lissPoints1 = liss.curve;
            auto liss1 = new VPointsShape(lissPoints1, 150, 150, GraphicStyle(2, graphics.theme.colorAccent));
            vectorContainers.addCreate(liss1);
        }
    }

}
