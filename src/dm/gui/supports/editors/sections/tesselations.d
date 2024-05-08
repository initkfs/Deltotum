module dm.gui.supports.editors.sections.tesselations;

import dm.gui.controls.control : Control;
import dm.math.rect2d : Rect2d;
import dm.kit.graphics.colors.rgba : RGBA;
import dm.kit.graphics.colors.palettes.material_palette : MaterialPalette;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;
import dm.kit.sprites.transitions.pause_transition : PauseTransition;
import dm.math.random : Random;
import dm.kit.sprites.textures.vectors.tessellations.penrose_tiling : PenroseTiling;
import dm.gui.containers.hbox : HBox;
import dm.gui.containers.vbox : VBox;

import std.stdio;

/**
 * Authors: initkfs
 */
class Tesselations : Control
{
    this()
    {
        import dm.kit.sprites.layouts.hlayout : HLayout;

        layout = new HLayout(5);
        layout.isAutoResize = true;
        isBackground = false;
        layout.isAlignY = false;
    }

    override void initialize()
    {
        super.initialize;
        enablePadding;
    }

    size_t[] modes = [0, 1, 2, 6, 7, 8, 10, 11];
    size_t currIndex;
    Random rnd;

    override void create()
    {
        super.create;

        rnd = new Random;

        auto root = new VBox(5);
        addCreate(root);
        root.enableInsets;

        auto root1 = new HBox(5);
        root.addCreate(root1);
        root1.enableInsets;

        auto t1 = new PenroseTiling(400, 200);
        t1.isMutable = true;
        t1.levels = 4;
        t1.lineWidth = 45 * t1.fi * t1.fi;
        randomTiling(t1);
        root1.addCreate(t1);

        auto transition = new PauseTransition(600);
        transition.isCycle = true;
        addCreate(transition);
        transition.onEndFrames ~= () { randomTiling(t1); t1.recreate; };

        t1.onPointerDown ~= (ref e) {
            if (transition.isRunning)
            {
                transition.stop;
                return;
            }
            transition.run;
        };

        auto vodRoot = new VBox(5);
        root1.addCreate(vodRoot);
        vodRoot.enableInsets;

        auto vodRoot1 = new HBox(5);
        vodRoot.addCreate(vodRoot1);
        vodRoot1.enableInsets;

        import dm.kit.sprites.textures.vectors.tessellations.voderberg : Voderberg, ShapeType;

        auto v1 = new Voderberg;
        v1.style = GraphicStyle(1, RGBA.web("#64b5f6"), false);
        v1.scale(10, 10);
        v1.shapeType = ShapeType.triangle;
        vodRoot1.addCreate(v1);

        auto v2 = new Voderberg;
        v2.style = GraphicStyle(1, RGBA.web("#dce775"), false);
        v2.scale(10, 10);
        v2.shapeType = ShapeType.voderberg;
        vodRoot1.addCreate(v2);

        auto v3 = new Voderberg;
        v3.style = GraphicStyle(1, RGBA.web("#f48fb1"), false);
        v3.scale(10, 10);
        v3.shapeType = ShapeType.bentwedge;
        vodRoot1.addCreate(v3);

        auto v4 = new Voderberg;
        v4.style = GraphicStyle(1, RGBA.web("#a5d6a7"), false);
        v4.shapeType = ShapeType.tent;
        v4.scale(15, 15);
        vodRoot1.addCreate(v4);

        auto noiseRoot1 = new HBox(5);
        root.addCreate(noiseRoot1);
        noiseRoot1.enableInsets;

        import dm.kit.sprites.textures.vectors.noises.perlin : Perlin;
        import dm.kit.sprites.textures.vectors.noises.open_simplex : OpenSimplex;
        import dm.kit.sprites.transitions.pause_transition : PauseTransition;
        import dm.math.random : Random;

        enum w = 100;
        enum h = 100;
        enum hue = 110;

        import dm.kit.sprites.textures.vectors.noises.samples.fractal_noise : FractalNoise;
        import dm.kit.sprites.textures.vectors.noises.samples.voronoi : Voronoi;
        import dm.kit.sprites.textures.vectors.noises.samples.value : Value;
        import dm.kit.sprites.textures.vectors.noises.samples.worley : Worley;
        import dm.kit.sprites.textures.vectors.noises.samples.simplex : Simplex;
        import dm.kit.sprites.textures.vectors.noises.samples.perlin : SPerlin = Perlin;

        uint seed = 0;

        auto frVor = new FractalNoise(new Voronoi(seed), w, h);
        frVor.noiseColor.hue = hue;
        frVor.valueScale = 3;
        noiseRoot1.addCreate(frVor);

        auto frWorl = new FractalNoise(new Worley(seed), w, h);
        frWorl.noiseColor.hue = 210;
        frWorl.valueScale = 2;
        noiseRoot1.addCreate(frWorl);

        auto frSimplex = new FractalNoise(new Simplex(seed), w, h);
        frSimplex.noiseColor.hue = 320;
        frSimplex.valueScale = 1.2;
        noiseRoot1.addCreate(frSimplex);

        auto frPerlin = new FractalNoise(new SPerlin(seed), w, h);
        frPerlin.noiseColor.hue = 10;
        frPerlin.valueScale = 1.2;
        noiseRoot1.addCreate(frPerlin);

         auto frVal = new FractalNoise(new Value(seed), w, h);
        frVal.noiseColor.hue = 130;
        frVal.noiseColor.saturation = 0.3;
        frVal.valueScale = 1.2;
        noiseRoot1.addCreate(frVal);

        auto noiseRoot2 = new HBox(5);
        root.addCreate(noiseRoot2);
        noiseRoot2.enableInsets;

        auto perlin = new Perlin(w, h);
        perlin.noiseColor.hue = hue;
        noiseRoot2.addCreate(perlin);

        auto simplex = new OpenSimplex(w, h);
        simplex.noiseColor.hue = 210;
        noiseRoot2.addCreate(simplex);

        import dm.kit.sprites.textures.vectors.noises.fractal_cell: FractalCell;
        auto fr1 = new FractalCell(w, h);
        fr1.noiseColor.hue = 50;
        noiseRoot2.addCreate(fr1);
    }

    private void randomTiling(PenroseTiling t)
    {
        foreach (ref c; t.colors)
        {
            c = RGBA.random;
        }
        t.lineColor = RGBA.random;
        if (currIndex >= modes.length)
        {
            currIndex = 0;
        }
        t.mode = modes[currIndex];
        currIndex++;
    }
}
