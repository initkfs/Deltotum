module api.dm.gui.supports.editors.sections.fractals;

// dfmt off
version(DmAddon):
// dfmt on

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.math.geom2.vec2 : Vec2d;
import api.math.random : Random;
import api.dm.gui.controls.containers.container: Container;
import api.dm.gui.controls.containers.hbox: HBox;

import Math = api.dm.math;

import std.stdio;

/**
 * Authors: initkfs
 */
class Fractals : Control
{
    private
    {
        enum shapeSize = 60;
        GraphicStyle shapeStyle = GraphicStyle.simple;
        Random random;
    }

    this()
    {
        id = "dm_gui_editor_section_fractals";

        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout;
        layout.isAutoResize = true;
        isBackground = false;

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

    protected Container newHContainer(){
        auto container = new HBox(10);
        container.layout.isAlign = true;
        return container;
    }

    Sprite2d createFractalInfo(string name, Sprite2d fractal, bool isDrawFromCenter = true, double translateX = 0, double translateY = 0, double rotateAngleDeg = 0)
    {
        import api.dm.gui.controls.containers.vbox : VBox;
        import api.dm.gui.controls.texts.text : Text;

        auto container = new VBox;
        buildInitCreate(container);

        auto label = new Text;
        label.text = name;
        container.addCreate(label);

        //fractal.isDrawBounds = true;
        fractal.angle = rotateAngleDeg;

        if (platform.cap.isVectorGraphics)
        {
            import api.dm.kit.sprites2d.textures.vectors.shapes.vpoints_shape : VPointsShape;

            if (auto shape = cast(VPointsShape) fractal)
            {
                shape.isDrawFromCenter = isDrawFromCenter;
                shape.translateX = translateX;
                shape.translateY = translateY;
            }
        }

        container.addCreate(fractal);

        return container;
    }

    override void create()
    {
        super.create;

        import api.dm.gui.controls.containers.center_box : CenterBox;
        import api.math.pos2.insets : Insets;

        auto container = newHContainer;
        addCreate(container);

        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
        import api.dm.kit.graphics.colors.rgba : RGBA;

        import api.dm.addon.fractals.fractal_generator : FractalGenerator;

        enum shapeSize = 100;

        auto fracGen = new FractalGenerator;
        fracGen.width = shapeSize;
        fracGen.height = shapeSize;
        build(fracGen);

        import MaterialPalette = api.dm.kit.graphics.colors.palettes.material_palette;

        enum lineWidth = 2;
        fracGen.style = GraphicStyle(lineWidth, RGBA.web(MaterialPalette.limeA400));

        container.addCreate(createFractalInfo("Heighway\ndragon", fracGen.heighwayDragon, false, shapeSize / 3, shapeSize / 3.5 - 5));

        fracGen.style = GraphicStyle(lineWidth, RGBA.web(MaterialPalette.amberA400));

        container.addCreate(createFractalInfo("Levy", fracGen.levyCurve, false, shapeSize / 3 - 5, shapeSize / 2));

        fracGen.style = GraphicStyle(lineWidth, RGBA.web(MaterialPalette.pinkA100));

        container.addCreate(createFractalInfo("Koch curve", fracGen.kochSnowflake, false, 10, shapeSize / 2));

        fracGen.style = GraphicStyle(lineWidth, RGBA.web(MaterialPalette.purpleA100));

        container.addCreate(createFractalInfo("Sierpinski\ntriangle", fracGen.sierpińskiTriangle, false, 10, shapeSize - 10));

        fracGen.style = GraphicStyle(lineWidth, RGBA.web(
                MaterialPalette.deeporangeA100));

        container.addCreate(createFractalInfo("Square\nSierpinski", fracGen.squareSierpinski, false, shapeSize / 2, 5));

        fracGen.style = GraphicStyle(lineWidth, RGBA.web(
                MaterialPalette.cyanA100));

        container.addCreate(createFractalInfo("Hexagonal\nGosper", fracGen.hexagonalGosper, false, shapeSize / 2, 0));

        fracGen.style = GraphicStyle(lineWidth, RGBA.web(
                MaterialPalette.limeA700));

        container.addCreate(createFractalInfo("Quadratic\nGosper", fracGen.quadraticGosper, false, 0, shapeSize));

        fracGen.style = GraphicStyle(lineWidth, RGBA.web(
                MaterialPalette.lightblue300));

        container.addCreate(createFractalInfo("Peano", fracGen.peano, false, 0, 0));

        fracGen.style = GraphicStyle(lineWidth, RGBA.web(
                MaterialPalette.purpleA700));

        container.addCreate(createFractalInfo("Triangle", fracGen.triangle, false, 70, 90));

        auto container2 = newHContainer;
        addCreate(container2);

        fracGen.style = GraphicStyle(lineWidth, RGBA.web(
                MaterialPalette.tealA100));

        container2.addCreate(createFractalInfo("Koch island", fracGen.kochIsland, false, 50, 0));

        fracGen.style = GraphicStyle(lineWidth, RGBA.web(
                MaterialPalette.purpleA200));

        container2.addCreate(createFractalInfo("Minkowski", fracGen.minkowski, false, 0, 60));

        fracGen.style = GraphicStyle(lineWidth, RGBA.web(
                MaterialPalette.lime500));

        container2.addCreate(createFractalInfo("Rings", fracGen.rings, false, 0, 0));

        fracGen.style = GraphicStyle(lineWidth, RGBA.web(
                MaterialPalette.cyan500));

        container2.addCreate(createFractalInfo("Crystal", fracGen.crystal, false, 0, 0));

        fracGen.style = GraphicStyle(lineWidth, RGBA.web(
                MaterialPalette.lightgreenA400));

        container2.addCreate(createFractalInfo("Board", fracGen.board, false, 0, 0));

        fracGen.style = GraphicStyle(lineWidth, RGBA.web(
                MaterialPalette.pinkA700));

        container2.addCreate(createFractalInfo("Hilbert", fracGen.hilbert, false, 0, 100));

        fracGen.style = GraphicStyle(lineWidth, RGBA.web(
                MaterialPalette.lime500));

        container2.addCreate(createFractalInfo("Tiles", fracGen.tiles, false, 90, 60));

        fracGen.style = GraphicStyle(lineWidth, RGBA.web(
                MaterialPalette.greenA400));

        container2.addCreate(createFractalInfo("Plant 1", fracGen.simplePlant, false, 0, 50, -90));
        container2.addCreate(createFractalInfo("Plant 2", fracGen.plant2, false, 10, 50, -90));
        container2.addCreate(createFractalInfo("Plant 3", fracGen.plant3, false, -20, 50, -90));
        container2.addCreate(createFractalInfo("Bush plant", fracGen.plantBushes, false, 0, 50, -90));

        auto container3 = newHContainer;
        addCreate(container3);

        import api.dm.addon.sprites.images.fractals.mandelbrot : Mandelbrot;

        auto mand = new Mandelbrot(shapeSize, shapeSize);
        mand.foregroundColor = RGBA.web(MaterialPalette.purpleA100);
        container3.addCreate(createFractalInfo("Mandelbrot", mand, false));

        import api.dm.addon.sprites.images.fractals.julia : Julia;

        auto julia = new Julia(shapeSize, shapeSize);
        container3.addCreate(createFractalInfo("Julia", julia, false));

        import api.dm.addon.sprites.images.fractals.newton : Newton;

        auto newton = new Newton(shapeSize, shapeSize);
        container3.addCreate(createFractalInfo("Newton", newton, false));
    }

}
