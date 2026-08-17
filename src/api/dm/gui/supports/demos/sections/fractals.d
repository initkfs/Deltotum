module api.dm.gui.supports.demos.sections.fractals;

import api.dm.gui.controls.containers.container;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.styles.gstyle : GStyle;
import api.math.geom2.vec2 : Vec2f;
import api.math.random : Random, rands;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.containers.hbox : HBox;

import api.dm.kit.procedural.lsystems.textures2d.lshape : LShape;
import api.dm.kit.procedural.lsystems.lsystem : LSystemData;
import LFractals = api.dm.kit.procedural.fractals.lfractals;

import Math = api.dm.math;

import std.stdio;
import api.math.matrices.affine3;

/**
 * Authors: initkfs
 */
class Fractals : Control
{
    private
    {
        GStyle shapeStyle = GStyle.simple;
        Random random;
    }

    float shapeSize = 100;

    this()
    {
        id = "dm_gui_editor_section_fractals";

        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout;
        layout.isAutoResize = true;
        isBackground = false;

        random = rands;
    }

    override void initialize()
    {
        super.initialize;
        enablePadding;
        shapeStyle = GStyle(2, theme.colorAccent);
    }

    T configureControl(T)(T sprite)
    {
        static if (is(T : Control))
        {
            sprite.isBorder = true;
        }
        return sprite;
    }

    protected Container newHContainer()
    {
        auto container = new HBox(10);
        return container;
    }

    protected LShape createShape(LSystemData data, GStyle style, bool isClosePath = false, bool isDrawFromCenter = true, float translateX = 0, float translateY = 0)
    {
        auto shape = new LShape(shapeSize, shapeSize, style, isClosePath, isDrawFromCenter);
        shape.translateX = translateX;
        shape.translateY = translateY;
        shape.data = data;
        return shape;
    }

    Container createVContainer()
    {
        import api.dm.gui.controls.containers.vbox : VBox;

        auto container = new VBox;
        container.isAlignX = true;
        buildInitCreate(container);
        return container;
    }

    Container createVTextContainer(string name)
    {
        import api.dm.gui.controls.texts.text: Text;

        auto container = createVContainer;
        auto label = new Text(name);
        container.addCreate(label);

        return container;
    }

    Sprite2d createFractalInfo(string name, LSystemData fractal, GStyle style, bool isDrawFromCenter = true, float translateX = 0, float translateY = 0, float rotateAngle = 0)
    {
        import api.dm.gui.controls.containers.vbox : VBox;
        import api.dm.gui.controls.texts.text : Text;

        auto container = createVTextContainer(name);

        if (platform.cap.isVector)
        {
            auto shape = createShape(fractal, style, false, isDrawFromCenter, translateX, translateY);
            shape.angle = rotateAngle;
            container.addCreate(shape);
        }

        return container;
    }

    Sprite2d createFractalInfo(string name, Sprite2d fractal)
    {
        auto container = createVTextContainer(name);
        container.addCreate(fractal);
        return container;
    }

    Control createFractalControlInfo(string name, Control fractal)
    {
        auto container = createVTextContainer(name);
        container.addCreate(fractal);
        return container;
    }

    override void create()
    {
        super.create;

        auto container = newHContainer;
        addCreate(container);

        import api.dm.kit.graphics.styles.gstyle : GStyle;
        import api.dm.kit.graphics.colors.rgba : RGBA;

        import MaterialPalette = api.dm.kit.graphics.colors.palettes.material_palette;

        enum lineWidth = 2;

        auto styleDragon = GStyle(lineWidth, RGBA.hex(MaterialPalette.limeA400));
        container.addCreate(createFractalInfo("Heighway\ndragon", LFractals.heighwayDragon, styleDragon, false, shapeSize / 2, shapeSize / 4));

        auto levyStyle = GStyle(lineWidth, RGBA.hex(MaterialPalette.amberA400));
        container.addCreate(createFractalInfo("Levy", LFractals.levyCurve, levyStyle, false, shapeSize / 4, shapeSize / 4));

        auto kochStyle = GStyle(lineWidth, RGBA.hex(MaterialPalette.pinkA100));
        container.addCreate(createFractalInfo("Koch curve", LFractals.kochSnowflake, kochStyle, false, shapeSize / 10, shapeSize / 4));

        auto sierpinskiStyle = GStyle(lineWidth, RGBA.hex(MaterialPalette.purpleA100));
        container.addCreate(createFractalInfo("Sierpinski\ntriangle", LFractals.sierpińskiTriangle, sierpinskiStyle, true, -shapeSize / 2.5, shapeSize / 5));

        auto squareSierpStyle = GStyle(lineWidth, RGBA.hex(MaterialPalette.deeporangeA100));
        container.addCreate(createFractalInfo("Square\nSierpinski", LFractals.squareSierpinski, squareSierpStyle, true, 0, -(
                shapeSize / 2) + 5));

        auto hgStyle = GStyle(lineWidth, RGBA.hex(MaterialPalette.cyanA100));
        container.addCreate(createFractalInfo("Hexagonal\nGosper", LFractals.hexagonalGosper, hgStyle, false, shapeSize / 2, 0));

        auto qgStyle = GStyle(lineWidth, RGBA.hex(MaterialPalette.limeA700));
        container.addCreate(createFractalInfo("Quadratic\nGosper", LFractals.quadraticGosper, qgStyle, true, -shapeSize / 2, shapeSize / 2));

        auto peanoStyle = GStyle(lineWidth, RGBA.hex(MaterialPalette.lightblue300));
        container.addCreate(createFractalInfo("Peano", LFractals.peano, peanoStyle, false, 0, 0));

        auto trigStyle = GStyle(lineWidth, RGBA.hex(MaterialPalette.purpleA700));
        container.addCreate(createFractalInfo("Triangle", LFractals.triangle, trigStyle, true, shapeSize / 5, shapeSize / 4));

        auto container2 = newHContainer;
        addCreate(container2);

        auto kistyle = GStyle(lineWidth, RGBA.hex(MaterialPalette.tealA100));
        container2.addCreate(createFractalInfo("Koch island", LFractals.kochIsland, kistyle, false, shapeSize / 2, 0));

        auto minkstyle = GStyle(lineWidth, RGBA.hex(MaterialPalette.purpleA200));
        container2.addCreate(createFractalInfo("Minkowski", LFractals.minkowski, minkstyle, false, 0, shapeSize / 2));

        auto ringstyle = GStyle(lineWidth, RGBA.hex(MaterialPalette.lime500));
        container2.addCreate(createFractalInfo("Rings", LFractals.rings, ringstyle, false, 0, 0));

        auto crstyle = GStyle(lineWidth, RGBA.hex(MaterialPalette.cyan500));
        container2.addCreate(createFractalInfo("Crystal", LFractals.crystal, crstyle, false, 0, 0));

        auto boardStyle = GStyle(lineWidth, RGBA.hex(MaterialPalette.lightgreenA400));
        container2.addCreate(createFractalInfo("Board", LFractals.board, boardStyle, false, 0, 0));

        auto hilstyle = GStyle(lineWidth, RGBA.hex(MaterialPalette.pinkA700));
        container2.addCreate(createFractalInfo("Hilbert", LFractals.hilbert, hilstyle, false, 0, 100));

        auto tileStyle = GStyle(lineWidth, RGBA.hex(MaterialPalette.lime500));
        container2.addCreate(createFractalInfo("Tiles", LFractals.tiles, tileStyle, true, shapeSize / 2 - 10, 0));

        auto plantStyle = GStyle(lineWidth, RGBA.hex(MaterialPalette.greenA400));

        container2.addCreate(createFractalInfo("Plant 1", LFractals.simplePlant, plantStyle, false, 0, shapeSize / 2, -90));
        container2.addCreate(createFractalInfo("Plant 2", LFractals.plant2, plantStyle, false, 0, shapeSize / 2, -90));
        container2.addCreate(createFractalInfo("Plant 3", LFractals.plant3, plantStyle, false, -(
                shapeSize / 4), shapeSize / 2, -90));
        container2.addCreate(createFractalInfo("Bush plant", LFractals.plantBushes, plantStyle, false, 0, shapeSize / 2, -90));

        auto container3 = newHContainer;
        addCreate(container3);

        import api.dm.kit.procedural.fractals.images.mandelbrot : Mandelbrot;

        auto mand = new Mandelbrot(shapeSize, shapeSize);
        mand.foregroundColor = RGBA.hex(MaterialPalette.purpleA100);
        container3.addCreate(createFractalInfo("Mandelbrot", mand));

        import api.dm.kit.procedural.fractals.images.julia : Julia;

        auto julia = new Julia(shapeSize, shapeSize);
        container3.addCreate(createFractalInfo("Julia", julia));

        import api.dm.kit.procedural.fractals.images.newton : Newton;

        auto newton = new Newton(shapeSize, shapeSize);
        container3.addCreate(createFractalInfo("Newton", newton));

        import api.dm.kit.procedural.fractals.images.phoenix : Phoenix;

        auto ph = new Phoenix(shapeSize, shapeSize);
        container3.addCreate(createFractalInfo("Phoenix", ph));
    }

}
