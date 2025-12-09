module api.dm.gui.supports.editors.sections.fractals;

import api.dm.gui.controls.containers.container;

// dfmt off
version(DmAddon):
// dfmt on

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.math.geom2.vec2 : Vec2d;
import api.math.random : Random;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.containers.hbox : HBox;

import api.dm.addon.procedural.lsystems.textures.lshape : LShape;
import api.dm.addon.procedural.lsystems.lsystem : LSystemData;
import LFractals = api.dm.addon.procedural.fractals.lfractals;

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
        GraphicStyle shapeStyle = GraphicStyle.simple;
        Random random;
    }

    double shapeSize = 100;

    this()
    {
        id = "dm_gui_editor_section_fractals";

        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout;
        layout.isAutoResize = true;
        isBackground = false;
        layout.isAlignY = true;

        random = new Random;
    }

    override void initialize()
    {
        super.initialize;
        enablePadding;
        shapeStyle = GraphicStyle(2, theme.colorAccent);
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
        container.layout.isAlignY = true;
        return container;
    }

    protected LShape createShape(LSystemData data, GraphicStyle style, bool isClosePath = false, bool isDrawFromCenter = true, double translateX = 0, double translateY = 0)
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

    Sprite2d createFractalInfo(string name, LSystemData fractal, GraphicStyle style, bool isDrawFromCenter = true, double translateX = 0, double translateY = 0, double rotateAngle = 0)
    {
        import api.dm.gui.controls.containers.vbox : VBox;
        import api.dm.gui.controls.texts.text : Text;

        auto container = createVTextContainer(name);

        if (platform.cap.isVectorGraphics)
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

        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
        import api.dm.kit.graphics.colors.rgba : RGBA;

        import MaterialPalette = api.dm.kit.graphics.colors.palettes.material_palette;

        enum lineWidth = 2;

        auto styleDragon = GraphicStyle(lineWidth, RGBA.web(MaterialPalette.limeA400));
        container.addCreate(createFractalInfo("Heighway\ndragon", LFractals.heighwayDragon, styleDragon, false, shapeSize / 2, shapeSize / 4));

        auto levyStyle = GraphicStyle(lineWidth, RGBA.web(MaterialPalette.amberA400));
        container.addCreate(createFractalInfo("Levy", LFractals.levyCurve, levyStyle, false, shapeSize / 4, shapeSize / 4));

        auto kochStyle = GraphicStyle(lineWidth, RGBA.web(MaterialPalette.pinkA100));
        container.addCreate(createFractalInfo("Koch curve", LFractals.kochSnowflake, kochStyle, false, shapeSize / 10, shapeSize / 4));

        auto sierpinskiStyle = GraphicStyle(lineWidth, RGBA.web(MaterialPalette.purpleA100));
        container.addCreate(createFractalInfo("Sierpinski\ntriangle", LFractals.sierpińskiTriangle, sierpinskiStyle, true, -shapeSize / 2.5, shapeSize / 5));

        auto squareSierpStyle = GraphicStyle(lineWidth, RGBA.web(MaterialPalette.deeporangeA100));
        container.addCreate(createFractalInfo("Square\nSierpinski", LFractals.squareSierpinski, squareSierpStyle, true, 0, -(
                shapeSize / 2) + 5));

        auto hgStyle = GraphicStyle(lineWidth, RGBA.web(MaterialPalette.cyanA100));
        container.addCreate(createFractalInfo("Hexagonal\nGosper", LFractals.hexagonalGosper, hgStyle, false, shapeSize / 2, 0));

        auto qgStyle = GraphicStyle(lineWidth, RGBA.web(MaterialPalette.limeA700));
        container.addCreate(createFractalInfo("Quadratic\nGosper", LFractals.quadraticGosper, qgStyle, true, -shapeSize / 2, shapeSize / 2));

        auto peanoStyle = GraphicStyle(lineWidth, RGBA.web(MaterialPalette.lightblue300));
        container.addCreate(createFractalInfo("Peano", LFractals.peano, peanoStyle, false, 0, 0));

        auto trigStyle = GraphicStyle(lineWidth, RGBA.web(MaterialPalette.purpleA700));
        container.addCreate(createFractalInfo("Triangle", LFractals.triangle, trigStyle, true, shapeSize / 5, shapeSize / 4));

        auto container2 = newHContainer;
        addCreate(container2);

        auto kistyle = GraphicStyle(lineWidth, RGBA.web(MaterialPalette.tealA100));
        container2.addCreate(createFractalInfo("Koch island", LFractals.kochIsland, kistyle, false, shapeSize / 2, 0));

        auto minkstyle = GraphicStyle(lineWidth, RGBA.web(MaterialPalette.purpleA200));
        container2.addCreate(createFractalInfo("Minkowski", LFractals.minkowski, minkstyle, false, 0, shapeSize / 2));

        auto ringstyle = GraphicStyle(lineWidth, RGBA.web(MaterialPalette.lime500));
        container2.addCreate(createFractalInfo("Rings", LFractals.rings, ringstyle, false, 0, 0));

        auto crstyle = GraphicStyle(lineWidth, RGBA.web(MaterialPalette.cyan500));
        container2.addCreate(createFractalInfo("Crystal", LFractals.crystal, crstyle, false, 0, 0));

        auto boardStyle = GraphicStyle(lineWidth, RGBA.web(MaterialPalette.lightgreenA400));
        container2.addCreate(createFractalInfo("Board", LFractals.board, boardStyle, false, 0, 0));

        auto hilstyle = GraphicStyle(lineWidth, RGBA.web(MaterialPalette.pinkA700));
        container2.addCreate(createFractalInfo("Hilbert", LFractals.hilbert, hilstyle, false, 0, 100));

        auto tileStyle = GraphicStyle(lineWidth, RGBA.web(MaterialPalette.lime500));
        container2.addCreate(createFractalInfo("Tiles", LFractals.tiles, tileStyle, true, shapeSize / 2 - 10, 0));

        auto plantStyle = GraphicStyle(lineWidth, RGBA.web(MaterialPalette.greenA400));

        container2.addCreate(createFractalInfo("Plant 1", LFractals.simplePlant, plantStyle, false, 0, shapeSize / 2, -90));
        container2.addCreate(createFractalInfo("Plant 2", LFractals.plant2, plantStyle, false, 0, shapeSize / 2, -90));
        container2.addCreate(createFractalInfo("Plant 3", LFractals.plant3, plantStyle, false, -(
                shapeSize / 4), shapeSize / 2, -90));
        container2.addCreate(createFractalInfo("Bush plant", LFractals.plantBushes, plantStyle, false, 0, shapeSize / 2, -90));

        auto container3 = newHContainer;
        addCreate(container3);

        import api.dm.addon.procedural.fractals.images.mandelbrot : Mandelbrot;

        auto mand = new Mandelbrot(shapeSize, shapeSize);
        mand.foregroundColor = RGBA.web(MaterialPalette.purpleA100);
        container3.addCreate(createFractalInfo("Mandelbrot", mand));

        import api.dm.addon.procedural.fractals.images.julia : Julia;

        auto julia = new Julia(shapeSize, shapeSize);
        container3.addCreate(createFractalInfo("Julia", julia));

        import api.dm.addon.procedural.fractals.images.newton : Newton;

        auto newton = new Newton(shapeSize, shapeSize);
        container3.addCreate(createFractalInfo("Newton", newton));
    }

}
