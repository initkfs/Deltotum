module api.dm.gui.supports.editors.sections.curves;

// dfmt off
version(DmAddon):
// dfmt on

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.math.geom2.vec2 : Vec2f;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.containers.hbox : HBox;

import CurveCalc = api.dm.addon.math.curves;

import Math = api.dm.math;

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

        Vec2f[] pointsBuffer;
        bool delegate(Vec2f) onBuffer;
    }

    this()
    {
        id = "dm_gui_editor_section_curves";

        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout;
        layout.isAutoResize = true;
        isBackground = false;
    }

    override void initialize()
    {
        super.initialize;
        enablePadding;
        shapeStyle = GraphicStyle(2, theme.colorAccent);

        onBuffer = (p) { pointsBuffer ~= p; return true; };
    }

    T configureControl(T)(T sprite)
    {
        static if (is(T : Control))
        {
            sprite.isBorder = true;
        }
        return sprite;
    }

    Sprite2d createCurveInfo(string name, Vec2f[] points, bool isDrawFromCenter = true, bool isClosePath = false)
    {
        import api.dm.gui.controls.containers.vbox : VBox;
        import api.dm.gui.controls.texts.text : Text;

        auto container = new VBox;
        container.layout.isAlignX = true;
        buildInitCreate(container);

        auto label = new Text;
        label.text = name;
        container.addCreate(label);

        Sprite2d shape;
        if (platform.cap.isVectorGraphics)
        {
            import api.dm.kit.sprites2d.textures.vectors.shapes.vpoints_shape : VPointsShape;

            shape = new VPointsShape(points, shapeSize, shapeSize, shapeStyle, isClosePath, isDrawFromCenter);
        }
        else
        {
            import api.dm.kit.sprites2d.shapes.points_shape : PointsShape;

            shape = new PointsShape(shapeSize, shapeSize, shapeStyle, points, isClosePath, isDrawFromCenter);
        }

        container.addCreate(shape);
        return container;
    }

    protected Container newHContainer()
    {
        auto container = new HBox(10);
        container.layout.isAlign = true;
        return container;
    }

    override void create()
    {
        super.create;

        import api.dm.gui.controls.containers.container : Container;
        import api.dm.gui.controls.containers.hbox : HBox;
        import api.dm.gui.controls.containers.vbox : VBox;
        import api.dm.gui.controls.containers.container : Container;
        import api.dm.gui.controls.containers.center_box : CenterBox;
        import api.math.pos2.insets : Insets;

        auto planeShapeContainer = newHContainer;
        addCreate(planeShapeContainer);

        assert(onBuffer);

        CurveCalc.archimedean(onBuffer, 4, 1, 4);
        auto spirs1 = createCurveInfo("Archimedean", pointsBuffer);
        resetBuffer;

        CurveCalc.lituus(onBuffer, 2, 8, 10);
        auto spirs2 = createCurveInfo("Lituus", pointsBuffer);
        resetBuffer;

        CurveCalc.cochleoid(onBuffer, 4, 8, 30);
        auto spirs3 = createCurveInfo("Cochleoid", pointsBuffer);
        resetBuffer;

        CurveCalc.bicorn(onBuffer, 25, 0.01, 1000, 1);
        auto bicorn1 = createCurveInfo("Bicorn", pointsBuffer);
        resetBuffer;

        CurveCalc.cardioid(onBuffer, 6);
        auto card1 = createCurveInfo("Cardioid", pointsBuffer);
        resetBuffer;

        CurveCalc.lemniscateBernoulli(onBuffer, 15);
        auto lem1 = createCurveInfo("Lemniscate\nBernoulli", pointsBuffer);
        resetBuffer;

        CurveCalc.witchOfAgnesi(onBuffer, 20);
        auto agnesi1 = createCurveInfo("Witch of\nAgnesi", pointsBuffer, true, false);
        resetBuffer;

        CurveCalc.tractrix(onBuffer, 20);
        auto tractrix1 = createCurveInfo("Tractrix", pointsBuffer);
        resetBuffer;

        CurveCalc.strophoid(onBuffer, 3.14 / 2, 0.01, 10);
        auto stroph1 = createCurveInfo("Strophoid", pointsBuffer);
        resetBuffer;

        CurveCalc.foliumOfDescartes(onBuffer, 3.14 / 2, 0.01, 10);
        auto decart1 = createCurveInfo("Descart\nfolium", pointsBuffer);
        resetBuffer;

        CurveCalc.trisectrixMaclaurin(onBuffer, 20);
        auto cube1 = createCurveInfo("Trisectrix of\nMaclaurin", pointsBuffer, true, false);
        resetBuffer;

        planeShapeContainer.addCreate([
            spirs1, spirs2, spirs3, bicorn1, card1, lem1, agnesi1, tractrix1,
            stroph1,
            decart1, cube1
        ]);

        auto planeShapeContainer2 = newHContainer;
        addCreate(planeShapeContainer2);

        CurveCalc.cycloid(onBuffer, 2);
        auto cycl = createCurveInfo("Cycloid", pointsBuffer);
        resetBuffer;

        CurveCalc.hypotrochoid(onBuffer, 15, 1, 5, 5);
        auto cycl1 = createCurveInfo("Hypotrochoid", pointsBuffer, true, true);
        resetBuffer;

        CurveCalc.hypotrochoid(onBuffer, 15, 1, 7, 10);
        auto cycl2 = createCurveInfo("Hypotrochoid", pointsBuffer, true, true);
        resetBuffer;

        CurveCalc.hypotrochoid(onBuffer, 15, 1, 13, 20);
        auto cycl3 = createCurveInfo("Hypotrochoid", pointsBuffer, true, true);
        resetBuffer;

        planeShapeContainer2.addCreate([
            cycl, cycl1, cycl2, cycl3
        ]);

        enum lissApmplitude = 20;

        CurveCalc.lissajous(onBuffer, lissApmplitude, 1, lissApmplitude, 2, Math
                .PI);
        auto liss1 = createCurveInfo("Lissajous 1:2", pointsBuffer);
        resetBuffer;

        CurveCalc.lissajous(onBuffer, lissApmplitude, 3, lissApmplitude, 2, Math
                .PI);
        auto liss2 = createCurveInfo("Lissajous 3:2", pointsBuffer);
        resetBuffer;

        CurveCalc.lissajous(onBuffer, lissApmplitude, 5, lissApmplitude, 4, Math
                .PI);
        auto liss3 = createCurveInfo("Lissajous 5:4", pointsBuffer);
        resetBuffer;

        CurveCalc.lissajous(onBuffer, lissApmplitude, 9, lissApmplitude, 8, Math
                .PI);
        auto liss4 = createCurveInfo("Lissajous 9:8", pointsBuffer);
        resetBuffer;

        planeShapeContainer2.addCreate([
            liss1, liss2, liss3, liss4
        ]);

        auto planeShapeContainer3 = newHContainer;
        addCreate(planeShapeContainer3);

        CurveCalc.rose(onBuffer, 25, 3, 1);
        auto rose1 = createCurveInfo("Rose 3", pointsBuffer);
        resetBuffer;

        CurveCalc.rose(onBuffer, 25, 5, 1);
        auto rose2 = createCurveInfo("Rose 5", pointsBuffer);
        resetBuffer;

        CurveCalc.rose(onBuffer, 25, 4, 7, 14);
        auto rose3 = createCurveInfo("Rose 4/7", pointsBuffer);
        resetBuffer;

        CurveCalc.rose(onBuffer, 25, 5, 7, 7);
        auto rose4 = createCurveInfo("Rose 5/7", pointsBuffer);
        resetBuffer;

        CurveCalc.rose(onBuffer, 25, 3, 2, 7);
        auto rose5 = createCurveInfo("Rose 3/2", pointsBuffer);
        resetBuffer;

        CurveCalc.rose(onBuffer, 25, 7, 2, 7);
        auto rose6 = createCurveInfo("Rose 7/2", pointsBuffer);
        resetBuffer;

        CurveCalc.rose(onBuffer, 25, 6, 3, 7);
        auto rose7 = createCurveInfo("Rose 6/3", pointsBuffer);
        resetBuffer;

        planeShapeContainer3.addCreate([
            rose1, rose2, rose3, rose4, rose5, rose6, rose7
        ]);

        auto planeShapeContainer4 = newHContainer;
        addCreate(planeShapeContainer4);

        CurveCalc.superellipse(onBuffer, 1, 1, 0.5, 20);
        auto supel1 = createCurveInfo("Superellipse\n1, n=0.5", pointsBuffer);
        resetBuffer;

        CurveCalc.squircle(onBuffer, 20);
        auto supel2 = createCurveInfo("Squircle", pointsBuffer);
        resetBuffer;

        CurveCalc.superformula(onBuffer, 1, 1, 16, 0.5, 0.5, 16, 20);
        auto sup1 = createCurveInfo("Superformula\n16, 0.5, 0.5, 16", pointsBuffer);
        resetBuffer;

        CurveCalc.superformula(onBuffer, 1, 1, 12, 15, 20, 3, 20);
        auto sup2 = createCurveInfo("Superformula\n12, 15, 20, 3", pointsBuffer);
        resetBuffer;

        CurveCalc.superformula(onBuffer, 1, 1, 4, 0.5, 0.5, 4, 20);
        auto sup3 = createCurveInfo("Superformula\n4, 0.5, 0.5, 4", pointsBuffer);
        resetBuffer;

        CurveCalc.superformula(onBuffer, 1, 1, 5, 2, 6, 6, 10);
        auto sup4 = createCurveInfo("Superformula\n5, 2, 6, 6", pointsBuffer);
        resetBuffer;

        CurveCalc.superformula(onBuffer, 1, 1, 3, 5, 18, 18, 5);
        auto sup5 = createCurveInfo("Superformula\n3, 5, 18, 18", pointsBuffer);
        resetBuffer;

        planeShapeContainer4.addCreate([
            supel1, supel2, sup1, sup2, sup3, sup4, sup5
        ]);
    }

    void resetBuffer()
    {
        pointsBuffer = null;
    }

}
