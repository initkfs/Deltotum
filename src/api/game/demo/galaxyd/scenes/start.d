module api.game.demo.galaxyd.scenes.start;

import api.dm.kit.scenes.scene : Scene;
import api.dm.gui.containers.vbox : VBox;

import Math = api.dm.math;
import api.dm.addon.math.triangulations.delaunay_triangulator;

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
    import api.math.geom2.triangulate;
    import api.dm.kit.sprites.textures.vectors.shapes.vtriangle;

    Vec2d[] points;
    Triangle2d[] trigs;

    override void create()
    {
        super.create;

        import api.math;

        int nv = 30;
        int ntri = 0;

        points = new Vec2d[](nv + 3);

        import api.math.random: Random;

        auto rnd = new Random;

        for (int i = 0; i < points.length; i++)
        {
            auto x = rnd.randomBetween!int(0, window.width);
            auto y = rnd.randomBetween!int(0, window.height);
            points[i] = Vec2d(x, y);
        }

         import std;

        points.sort!((p1, p2) => p1.x < p2.x);


        trigs = triangulate(points);

        createDebugger;
    }

    override void draw()
    {
        super.draw;

        import api.dm.kit.graphics.colors.rgba: RGBA;

        graphics.setColor(RGBA.red);
        scope(exit){
            graphics.restoreColor;        
        }

        foreach (p; points)
        {
            graphics.circle(p.x, p.y, 5, RGBA.red);
        }

        foreach (Triangle2d trig; trigs)
        {
            graphics.line(trig.a, trig.b);
            graphics.line(trig.b ,trig.c);
            graphics.line(trig.c, trig.a);
        }
    }
}
