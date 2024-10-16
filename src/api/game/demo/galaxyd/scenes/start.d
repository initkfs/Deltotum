module api.game.demo.galaxyd.scenes.start;

import api.dm.kit.scenes.scene : Scene;
import api.dm.gui.containers.vbox : VBox;

import Math = api.dm.math;
import api.dm.addon.math.triangulations.delaunay_triangulator;
import api.math.random: Random;

/**
 * Authors: initkfs
 */
class Start : Scene
{
    this()
    {
        name = "start";
    }

    import api.math;
    import api.dm.addon.math.geom2.triangulate;
    import api.dm.kit.sprites.textures.vectors.shapes.vtriangle;
    import api.math.geom2.convex_hull;

    Vec2d[] points;
    Line2d[] lines;
    Line2d[Vec2d] clusters;
    Vec2d[] vertex;

    Random rnd;


    override void create()
    {
        super.create;

        rnd = new Random;

        import api.math;

        enum pCount = 100;
        points = new Vec2d[](pCount);

        foreach(pi; 0..pCount){
            auto rx = rnd.randomBetween(0, 500);
            auto ry = rnd.randomBetween(0, 500);
            points[pi] = Vec2d(rx, ry);
        }

        vertex = graham(points);

        

        // Line2d clasterStart;

        // foreach (ref Line2d line; lines)
        // {
        //     if(line)   
        // }
       
        createDebugger;
    }

    override void draw()
    {
        super.draw;

        import api.dm.kit.graphics.colors.rgba : RGBA;

        graphics.changeColor(RGBA.red);

        foreach (ref p; points)
        {
            graphics.fillCircle(p.x, p.y, 5);
        }

        graphics.restoreColor;

        foreach (ref v; vertex)
        {
            graphics.fillCircle(v.x, v.y, 2, RGBA.yellow);
        }

        // graphics.changeColor(RGBA.green);

        // foreach (Line2d line; lines)
        // {
        //     graphics.line(line);
        // }
    }
}
