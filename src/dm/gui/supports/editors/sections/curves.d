module dm.gui.supports.editors.sections.curves;

import dm.gui.controls.control : Control;
import dm.kit.sprites.sprite : Sprite;
import dm.kit.graphics.colors.rgba : RGBA;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;
import dm.math.vector2 : Vector2;
import dm.gui.containers.container: Container;
import dm.gui.containers.hbox: HBox;

import Math = dm.math;

import std.stdio;

/**
 * Authors: initkfs
 */
class Curves : Control
{
    private
    {
        enum shapeSize = 60;
        GraphicStyle shapeStyle = GraphicStyle.simple;
    }

    this()
    {
        id = "dm_gui_editor_section_curves";

        import dm.kit.sprites.layouts.vlayout : VLayout;

        layout = new VLayout(5);
        layout.isAutoResize = true;
        isBackground = false;
    }

    override void initialize()
    {
        super.initialize;
        enablePadding;
        shapeStyle = GraphicStyle(2, graphics.theme.colorAccent);
    }

    T configureControl(T)(T sprite)
    {
        static if (is(T : Control))
        {
            sprite.isBorder = true;
        }
        return sprite;
    }

    Sprite createCurveInfo(string name, Vector2[] points, bool isDrawFromCenter = true, bool isClosePath = false)
    {
        import dm.gui.containers.vbox : VBox;
        import dm.gui.controls.texts.text : Text;

        auto container = new VBox;
        container.layout.isAlign = true;
        buildCreate(container);

        auto label = new Text;
        label.text = name;
        container.addCreate(label);

        Sprite shape;
        if (capGraphics.isVectorGraphics)
        {
            import dm.kit.sprites.textures.vectors.vpoints_shape: VPointsShape;

            shape = new VPointsShape(points, shapeSize, shapeSize, shapeStyle, isClosePath, isDrawFromCenter);
        }
        else
        {
            import dm.kit.sprites.shapes.points_shape : PointsShape;

            shape = new PointsShape(shapeSize, shapeSize, shapeStyle, points, isClosePath, isDrawFromCenter);
        }

        container.addCreate(shape);
        return container;
    }

    protected Container newHContainer(){
        auto container = new HBox(10);
        container.layout.isAlign = true;
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

        auto planeShapeContainer = newHContainer;
        addCreate(planeShapeContainer);

        import dm.addon.math.curves.spirals : Spirals;

        auto spiralCalc = new Spirals;

        auto spirs1 = createCurveInfo("Archimedean", spiralCalc.archimedean(4, 1, 4));
        auto spirs2 = createCurveInfo("Lituus", spiralCalc.lituus(2, 8, 10));
        auto spirs3 = createCurveInfo("Cochleoid", spiralCalc.cochleoid(4, 8, 30));

        import dm.addon.math.curves.plane_curves : PlaneCurve;

        auto planeCurveCalc = new PlaneCurve;

        Vector2[] bicornPoints = planeCurveCalc.bicorn(25, 0.01, 1000, 1);
        auto bicorn1 = createCurveInfo("Bicorn", bicornPoints);

        Vector2[] cardPoints = planeCurveCalc.cardioid(6);
        auto card1 = createCurveInfo("Cardioid", cardPoints);

        Vector2[] lemPoints = planeCurveCalc.lemniscateBernoulli(15);
        auto lem1 = createCurveInfo("Lemniscate\nBernoulli", lemPoints);

        Vector2[] agnesi1Points = planeCurveCalc.witchOfAgnesi(20);
        auto agnesi1 = createCurveInfo("Witch of \n Agnesi", agnesi1Points, true, false);

        auto tractrix1 = createCurveInfo("Tractrix", planeCurveCalc.tractrix(20));

        auto stroph1 = createCurveInfo("Strophoid", planeCurveCalc.strophoid(3.14 / 2, 0.01, 10));

        auto decart1 = createCurveInfo("Descart\nfolium", planeCurveCalc.foliumOfDescartes(3.14 / 2, 0.01, 10));

        import dm.addon.math.curves.cubic_plane_curves : CubicPlaneCurves;

        auto cubicCurveCalc = new CubicPlaneCurves;
        Vector2[] cub1Points = cubicCurveCalc.trisectrixMaclaurin(20);
        auto cube1 = createCurveInfo("Trisectrix of \nMaclaurin", cub1Points, true, false);

        planeShapeContainer.addCreate([
            spirs1, spirs2, spirs3, bicorn1, card1, lem1, agnesi1, tractrix1,
            stroph1,
            decart1, cube1
        ]);

        auto superellipseContainer = newHContainer;
        addCreate(superellipseContainer);

        import dm.addon.math.curves.superellipse : Superellipse;

        auto ellipseCuveCalc = new Superellipse;

        auto supel1 = createCurveInfo("Superellipse\n 1, n=0.5", ellipseCuveCalc.superellipse(1, 1, 0.5, 20));
        auto supel2 = createCurveInfo("Squircle", ellipseCuveCalc.squircle(20));

        Vector2[] sup1Points = ellipseCuveCalc.superformula(1, 1, 16, 0.5, 0.5, 16, 20);
        auto sup1 = createCurveInfo("Superformula\n 16, 0.5, 0.5, 16", sup1Points);

        Vector2[] sup2Points = ellipseCuveCalc.superformula(1, 1, 12, 15, 20, 3, 20);
        auto sup2 = createCurveInfo("Superformula\n 12, 15, 20, 3", sup2Points);

        Vector2[] sup3Points = ellipseCuveCalc.superformula(1, 1, 4, 0.5, 0.5, 4, 20);
        auto sup3 = createCurveInfo("Superformula\n 4, 0.5, 0.5, 4", sup3Points);

        Vector2[] sup4Points = ellipseCuveCalc.superformula(1, 1, 5, 2, 6, 6, 10);
        auto sup4 = createCurveInfo("Superformula\n 5, 2, 6, 6", sup4Points);

        Vector2[] sup5Points = ellipseCuveCalc.superformula(1, 1, 3, 5, 18, 18, 5);
        auto sup5 = createCurveInfo("Superformula\n 3, 5, 18, 18", sup5Points);

        superellipseContainer.addCreate([
            supel1, supel2, sup1, sup2, sup3, sup4, sup5
        ]);

        auto rosesContainer = newHContainer;
        addCreate(rosesContainer);

        import dm.addon.math.curves.roses : Roses;

        auto rosesCuveCalc = new Roses;
        auto rose1 = createCurveInfo("Rose 3", rosesCuveCalc.rose(25, 3, 1));
        auto rose2 = createCurveInfo("Rose 5", rosesCuveCalc.rose(25, 5, 1));
        auto rose3 = createCurveInfo("Rose 4/7", rosesCuveCalc.rose(25, 4, 7, 14));
        auto rose4 = createCurveInfo("Rose 5/7", rosesCuveCalc.rose(25, 5, 7, 7));
        auto rose5 = createCurveInfo("Rose 3/2", rosesCuveCalc.rose(25, 3, 2, 7));
        auto rose6 = createCurveInfo("Rose 7/2", rosesCuveCalc.rose(25, 7, 2, 7));
        auto rose7 = createCurveInfo("Rose 6/3", rosesCuveCalc.rose(25, 6, 3, 7));

        rosesContainer.addCreate([
            rose1, rose2, rose3, rose4, rose5, rose6, rose7
        ]);

        import dm.addon.math.curves.cycloidal : Cycloidal;

        auto cyclContainer = newHContainer;
        addCreate(cyclContainer);

        auto cyclCuveCalc = new Cycloidal;

        auto cycl = createCurveInfo("Cycloid", cyclCuveCalc.cycloid(2));
        auto cycl1 = createCurveInfo("Hypotrochoid", cyclCuveCalc.hypotrochoid(15, 1, 5, 5), true, true);
        auto cycl2 = createCurveInfo("Hypotrochoid", cyclCuveCalc.hypotrochoid(15, 1, 7, 10), true, true);
        auto cycl3 = createCurveInfo("Hypotrochoid", cyclCuveCalc.hypotrochoid(15, 1, 13, 20), true, true);

        cyclContainer.addCreate([
                cycl, cycl1, cycl2, cycl3
            ]);

        import dm.addon.math.curves.lissajous : Lissajous;

        auto lissContainer = newHContainer;
        addCreate(lissContainer);

        auto lissCuveCalc = new Lissajous;

        enum lissApmplitude = 20;

        auto liss1 = createCurveInfo("Lissajous 1:2", lissCuveCalc.curve(lissApmplitude, 1, lissApmplitude, 2, Math
                .PI));
        auto liss2 = createCurveInfo("Lissajous 3:2", lissCuveCalc.curve(lissApmplitude, 3, lissApmplitude, 2, Math
                .PI));
        auto liss3 = createCurveInfo("Lissajous 5:4", lissCuveCalc.curve(lissApmplitude, 5, lissApmplitude, 4, Math
                .PI));
        auto liss4 = createCurveInfo("Lissajous 9:8", lissCuveCalc.curve(lissApmplitude, 9, lissApmplitude, 8, Math
                .PI));

        lissContainer.addCreate([
                liss1, liss2, liss3, liss4
            ]);
    }

}
