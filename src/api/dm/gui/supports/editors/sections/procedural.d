module api.dm.gui.supports.editors.sections.procedural;

// dfmt off
version(DmAddon):
// dfmt on

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.math.geom2.rect2 : Rect2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import MaterialPalette = api.dm.kit.graphics.colors.palettes.material_palette;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites2d.tweens.pause_tween2d : PauseTween2d;
import api.math.random : Random;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.gui.controls.containers.vbox : VBox;

import std.stdio;

/**
 * Authors: initkfs
 */
class Procedural : Control
{
    this()
    {
        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout;
        layout.isAutoResize = true;
    }

    override void initialize()
    {
        super.initialize;
        enablePadding;
    }

    Sprite2d createInfo(string name, Sprite2d content)
    {
        import api.dm.gui.controls.containers.vbox : VBox;
        import api.dm.gui.controls.texts.text : Text;

        auto container = new VBox;
        container.isAlignX = true;
        buildInitCreate(container);
        container.enablePadding;

        auto label = new Text(name);
        container.addCreate(label);

        container.addCreate(content);

        return container;
    }

    Random rnd;

    override void create()
    {
        super.create;

        rnd = new Random;

        auto mazeRoot = new HBox;
        mazeRoot.isAlignY = true;
        addCreate(mazeRoot);
        createMaze(mazeRoot);

        createNoise(mazeRoot);

        auto tilingRoot = new HBox;
        addCreate(tilingRoot);
        createTiling(tilingRoot);

        createCellulars(tilingRoot);
    }

    private void createTiling(Control root)
    {
        import api.dm.addon.procedural.tessellations.textures.penrose_tiling : PenroseTiling;

        static size_t[8] modes = [0, 1, 2, 6, 7, 8, 10, 11];
        static size_t currIndex;

        void delegate(PenroseTiling) randomTiling = (PenroseTiling t) {
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
        };

        auto t1 = new PenroseTiling(400, 200);
        t1.marginLeft = 25;
        t1.isMutable = true;
        t1.levels = 4;
        t1.lineWidth = 45 * t1.fi * t1.fi;
        randomTiling(t1);

        auto penroseRoot = createInfo("Penrose tiling", t1);
        root.addCreate(penroseRoot);

        import api.dm.kit.sprites2d.tweens.pause_tween2d : PauseTween2d;

        auto tween = new PauseTween2d(600);
        tween.isInfinite = true;
        penroseRoot.addCreate(tween);
        tween.onEnd ~= () { randomTiling(t1); t1.recreate; };

        t1.onPointerPress ~= (ref e) {
            if (tween.isRunning)
            {
                tween.stop;
                return;
            }
            tween.run;
        };
    }

    void createCellulars(Control root)
    {
        import api.dm.addon.procedural.cellulars.elementary_cellular : ElementaryCellular;

        auto ca = new ElementaryCellular(90);
        ca.initializeState;

        auto cellsRoot = createInfo("Rule 90", ca);
        root.addCreate(cellsRoot);
    }

    void createMaze(Control mazeRoot)
    {
        import api.dm.addon.procedural.mazes.shapes.binary_tree : BinaryTree;

        enum mazeWidth = 150;
        enum mazeHeight = 150;

        auto binTree1 = new BinaryTree(mazeWidth, mazeHeight, 10, 10);
        binTree1.cellStyle = GraphicStyle(4, RGBA.lightpink);
        mazeRoot.addCreate(createInfo("Binary tree", binTree1));

        import api.dm.addon.procedural.mazes.shapes.sidewinder : Sidewinder;

        auto sidew1 = new Sidewinder(mazeWidth, mazeHeight, 10, 10);
        sidew1.cellStyle = GraphicStyle(4, RGBA.lightskyblue);
        mazeRoot.addCreate(createInfo("Sidewinder", sidew1));

        import api.dm.addon.procedural.mazes.shapes.aldous_broder : AldousBroder;

        auto aldBrod1 = new AldousBroder(mazeWidth, mazeHeight, 10, 10);
        aldBrod1.cellStyle = GraphicStyle(4, RGBA.lightgreen);
        mazeRoot.addCreate(createInfo("Aldous-Broder", aldBrod1));
    }

    void createNoise(Control noiseRoot)
    {
        enum w = 100;
        enum h = 100;
        enum hue = 110;

        import api.dm.addon.procedural.noises.textures.fractal_noise : FractalNoise;
        import api.dm.addon.procedural.noises.voronoi : Voronoi;
        import api.dm.addon.procedural.noises.value : Value;
        import api.dm.addon.procedural.noises.worley : Worley;
        import api.dm.addon.procedural.noises.simplex : Simplex;
        import api.dm.addon.procedural.noises.perlin : SPerlin = Perlin;
        import api.dm.addon.procedural.noises.textures.open_simplex : OpenSimplex;

        uint seed = 0;

        auto frVor = new FractalNoise(new Voronoi(seed), w, h);
        frVor.noiseColor.h = hue;
        frVor.valueScale = 3;
        noiseRoot.addCreate(createInfo("Voronoi", frVor));

        auto frWorl = new FractalNoise(new Worley(seed), w, h);
        frWorl.noiseColor.h = 210;
        frWorl.valueScale = 2;
        noiseRoot.addCreate(createInfo("Worley", frWorl));

        auto frSimplex = new FractalNoise(new Simplex(seed), w, h);
        frSimplex.noiseColor.h = 320;
        frSimplex.valueScale = 1.2;
        noiseRoot.addCreate(createInfo("Simplex", frSimplex));

        auto frPerlin = new FractalNoise(new SPerlin(seed), w, h);
        frPerlin.noiseColor.h = 10;
        frPerlin.valueScale = 1.2;
        noiseRoot.addCreate(createInfo("Perlin", frPerlin));

        auto frVal = new FractalNoise(new Value(seed), w, h);
        frVal.noiseColor.h = 130;
        frVal.noiseColor.s = 0.3;
        frVal.valueScale = 1.2;
        noiseRoot.addCreate(createInfo("Value", frVal));

        auto noiseRoot2 = new HBox(5);
        noiseRoot.addCreate(noiseRoot2);

        import api.dm.addon.procedural.noises.textures.perlin : Perlin;

        auto p2 = new Perlin;
        noiseRoot.addCreate(createInfo("Perlin 2", p2));

        import api.dm.addon.procedural.noises.textures.open_simplex : OpenSimplex;

        auto op2 = new OpenSimplex;
        noiseRoot.addCreate(createInfo("Simplex 2", op2));
    }
}
