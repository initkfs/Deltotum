module dm.gui.supports.editors.sections.tesselations;

import dm.gui.controls.control : Control;
import dm.math.rect2d : Rect2d;
import dm.kit.graphics.colors.rgba : RGBA;
import dm.kit.sprites.transitions.pause_transition : PauseTransition;
import dm.math.random : Random;
import dm.kit.sprites.textures.vectors.tessellations.penrose_tiling : PenroseTiling;

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

    size_t[] modes = [0, 1, 2, 6, 7, 8, 9, 10, 11];
    size_t currIndex;
    Random rnd;

    override void create()
    {
        super.create;

        import dm.gui.containers.hbox : HBox;

        rnd = new Random;

        auto root1 = new HBox(5);
        addCreate(root1);
        root1.enableInsets;

        auto t1 = new PenroseTiling(400, 200);
        t1.levels = 4;
        t1.lineWidth = 45 * t1.fi * t1.fi;
        randomTiling(t1);
        root1.addCreate(t1);

        auto transition = new PauseTransition(700);
        transition.isCycle = true;
        addCreate(transition);
        transition.onEndFrames ~= () { randomTiling(t1); t1.recreate; };

        onPointerDown ~= (ref e) {
            if (transition.isRunning)
            {
                transition.stop;
                return;
            }
            transition.run;
        };
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
