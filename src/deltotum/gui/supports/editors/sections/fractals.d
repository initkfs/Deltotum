module deltotum.gui.supports.editors.sections.fractals;

import deltotum.gui.controls.control : Control;
import deltotum.kit.sprites.sprite : Sprite;
import deltotum.kit.graphics.colors.rgba : RGBA;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.math.vector2d : Vector2d;
import deltotum.math.random : Random;

import Math = deltotum.math;

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
        id = "deltotum_gui_editor_section_fractals";

        import deltotum.kit.sprites.layouts.vlayout : VLayout;

        layout = new VLayout(5);
        layout.isAutoResize = true;
        isBackground = false;

        random = new Random;
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

    Sprite createFractalInfo(string name, Sprite fractal, bool isDrawFromCenter = true, double translateX = 0, double translateY = 0, double rotateAngleDeg = 0)
    {
        import deltotum.gui.containers.vbox : VBox;
        import deltotum.gui.controls.texts.text : Text;

        auto container = new VBox;
        buildCreate(container);

        auto label = new Text;
        label.text = name;
        container.addCreate(label);

        //fractal.isDrawBounds = true;
        fractal.angle = rotateAngleDeg;

        if (capGraphics.isVectorGraphics)
        {
            import deltotum.kit.graphics.shapes.vectors.vpoints_shape : VPointsShape;

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

        import deltotum.gui.containers.container : Container;
        import deltotum.gui.containers.hbox : HBox;
        import deltotum.gui.containers.vbox : VBox;
        import deltotum.gui.containers.container : Container;
        import deltotum.gui.containers.stack_box : StackBox;
        import deltotum.math.geom.insets : Insets;

        auto container = new HBox;
        addCreate(container);

        import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
        import deltotum.kit.graphics.colors.rgba : RGBA;

        import deltotum.kit.graphics.shapes.lsystems.fractal_generator : FractalGenerator;

        enum shapeSize = 100;

        auto fracGen = new FractalGenerator;
        fracGen.width = shapeSize;
        fracGen.height = shapeSize;
        build(fracGen);

        import deltotum.kit.graphics.colors.palettes.material_design_palette : MaterialDesignPalette;

        enum lineWidth = 2;
        fracGen.style = GraphicStyle(lineWidth, RGBA.web(MaterialDesignPalette.limeA400));

        container.addCreate(createFractalInfo("Heighway\ndragon", fracGen.heighwayDragon, false, shapeSize / 3, shapeSize / 3.5 - 5));

        fracGen.style = GraphicStyle(lineWidth, RGBA.web(MaterialDesignPalette.amberA400));

        container.addCreate(createFractalInfo("Levy", fracGen.levyCurve, false, shapeSize / 3 - 5, shapeSize / 2));

        fracGen.style = GraphicStyle(lineWidth, RGBA.web(MaterialDesignPalette.pinkA100));

        container.addCreate(createFractalInfo("Koch curve", fracGen.kochSnowflake, false, 10, shapeSize / 2));

        fracGen.style = GraphicStyle(lineWidth, RGBA.web(MaterialDesignPalette.purpleA100));

        container.addCreate(createFractalInfo("Sierpinski\ntriangle", fracGen.sierpińskiTriangle, false, 10, shapeSize - 10));

        fracGen.style = GraphicStyle(lineWidth, RGBA.web(
                MaterialDesignPalette.deeporangeA100));

        container.addCreate(createFractalInfo("Square\nSierpinski", fracGen.squareSierpinski, false, shapeSize / 2, 5));

        fracGen.style = GraphicStyle(lineWidth, RGBA.web(
                MaterialDesignPalette.cyanA100));

        container.addCreate(createFractalInfo("Hexagonal\nGosper", fracGen.hexagonalGosper, false, shapeSize / 2, 0));

        fracGen.style = GraphicStyle(lineWidth, RGBA.web(
                MaterialDesignPalette.limeA700));

        container.addCreate(createFractalInfo("Quadratic\nGosper", fracGen.quadraticGosper, false, 0, shapeSize));

        fracGen.style = GraphicStyle(lineWidth, RGBA.web(
                MaterialDesignPalette.lightblue300));

        container.addCreate(createFractalInfo("Peano", fracGen.peano, false, 0, 0));

        fracGen.style = GraphicStyle(lineWidth, RGBA.web(
                MaterialDesignPalette.purpleA700));

        container.addCreate(createFractalInfo("Triangle", fracGen.triangle, false, 70, 90));

        auto container2 = new HBox;
        addCreate(container2);

        fracGen.style = GraphicStyle(lineWidth, RGBA.web(
                MaterialDesignPalette.tealA100));

        container2.addCreate(createFractalInfo("Koch island", fracGen.kochIsland, false, 50, 0));

        fracGen.style = GraphicStyle(lineWidth, RGBA.web(
                MaterialDesignPalette.purpleA200));

        container2.addCreate(createFractalInfo("Minkowski", fracGen.minkowski, false, 0, 60));

        fracGen.style = GraphicStyle(lineWidth, RGBA.web(
                MaterialDesignPalette.lime500));

        container2.addCreate(createFractalInfo("Rings", fracGen.rings, false, 0, 0));

        fracGen.style = GraphicStyle(lineWidth, RGBA.web(
                MaterialDesignPalette.cyan500));

        container2.addCreate(createFractalInfo("Crystal", fracGen.crystal, false, 0, 0));

        fracGen.style = GraphicStyle(lineWidth, RGBA.web(
                MaterialDesignPalette.lightgreenA400));

        container2.addCreate(createFractalInfo("Board", fracGen.board, false, 0, 0));

        fracGen.style = GraphicStyle(lineWidth, RGBA.web(
                MaterialDesignPalette.pinkA700));

        container2.addCreate(createFractalInfo("Hilbert", fracGen.hilbert, false, 0, 100));

        fracGen.style = GraphicStyle(lineWidth, RGBA.web(
                MaterialDesignPalette.lime500));

        container2.addCreate(createFractalInfo("Tiles", fracGen.tiles, false, 90, 60));

        fracGen.style = GraphicStyle(lineWidth, RGBA.web(
                MaterialDesignPalette.greenA400));

        container2.addCreate(createFractalInfo("Plant 1", fracGen.simplePlant, false, 0, 50, -90));
        container2.addCreate(createFractalInfo("Plant 2", fracGen.plant2, false, 10, 50, -90));
        container2.addCreate(createFractalInfo("Plant 3", fracGen.plant3, false, -20, 50, -90));
        container2.addCreate(createFractalInfo("Bush plant", fracGen.plantBushes, false, 0, 50, -90));

        auto container3 = new HBox;
        addCreate(container3);

        import deltotum.kit.sprites.images.fractals.mandelbrot : Mandelbrot;

        auto mand = new Mandelbrot(shapeSize, shapeSize);
        mand.foregroundColor = RGBA.web(MaterialDesignPalette.purpleA100);
        container3.addCreate(createFractalInfo("Mandelbrot", mand, false));

        import deltotum.kit.sprites.images.fractals.julia : Julia;

        auto julia = new Julia(shapeSize, shapeSize);
        container3.addCreate(createFractalInfo("Julia", julia, false));

        import deltotum.kit.sprites.images.fractals.newton : Newton;

        auto newton = new Newton(shapeSize, shapeSize);
        container3.addCreate(createFractalInfo("Newton", newton, false));
    }

}
