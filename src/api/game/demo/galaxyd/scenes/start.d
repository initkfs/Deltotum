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

    XYZ[] points;
    ITRIANGLE[] triangles;

    Triangle2d[] trigs;

    override void create()
    {
        super.create;

        import api.math;

        int nv = 30;
        int ntri = 0;

        points = new XYZ[](nv + 3);

        import api.math.random: Random;

        auto rnd = new Random;

        for (int i = 0; i < points.length; i++)
        {
            auto x = rnd.randomBetween!int(0, window.width);
            auto y = rnd.randomBetween!int(0, window.height);
            points[i] = XYZ(x, y, 0.0);
        }

        import std;
        points.sort!((p1, p2) => p1.x < p2.x);


        triangles = new ITRIANGLE[](nv * 3);

        int bb = Triangulate(nv, points.ptr, triangles.ptr, &ntri);

        for (auto i = 0; i < ntri; i++)
        {
            auto x1 = points[triangles[i].p1].x;
            auto y1 = points[triangles[i].p1].y;
            auto x2 = points[triangles[i].p2].x;
            auto y2 = points[triangles[i].p2].y;
            auto x3 = points[triangles[i].p3].x;
            auto y3 = points[triangles[i].p3].y;

            trigs ~= Triangle2d(Vec2d(x1, y1), Vec2d(x2, y2), Vec2d(x3, y3));

        }

        import std;
        writeln(points);

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
