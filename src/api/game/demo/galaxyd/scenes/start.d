module api.game.demo.galaxyd.scenes.start;

import api.dm.kit.scenes.scene : Scene;
import api.dm.gui.containers.vbox : VBox;

import Math = api.dm.math;
import api.math.random : Random;

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
    import api.math.triangulations.bourke;
    import api.math.triangulations.fortune;
    import api.dm.kit.graphics.colors.rgba : RGBA;

    XYZ[] points;
    Vec2d[] lines;
    Vec2d[] vertex;
    Triangle2d[] trigs;
    Line2d[] sites;

    Random rnd;

    Line2d[][RGBA] clusters;
    Vec2d[] clustersLines = [Vec2d(0, 0)];

    override void create()
    {
        super.create;

        rnd = new Random;

        import api.math;

        int ntri = 0;

        enum pCount = 10;
        points = new XYZ[](pCount + 3);

        ITRIANGLE[] triangles = new ITRIANGLE[]((pCount) * 3);

        foreach (pi; 0 .. pCount)
        {
            auto rx = rnd.randomBetween(0, 500);
            auto ry = rnd.randomBetween(0, 500);
            points[pi] = XYZ(rx, ry, 0);
        }

        import std;
        points.sort!((p1, p2) => p1.x < p2.x);

        triangulate(cast(int) points.length, points.ptr, triangles.ptr, &ntri);

        foreach (i; 0 .. ntri)
        {
            auto tx1 = points[triangles[i].p1].x;
            auto ty1 = points[triangles[i].p1].y;
            auto tx2 = points[triangles[i].p2].x;
            auto ty2 = points[triangles[i].p2].y;
            auto tx3 = points[triangles[i].p3].x;
            auto ty3 = points[triangles[i].p3].y;

            trigs ~= Triangle2d(Vec2d(tx1, ty1), Vec2d(tx2, ty2), Vec2d(tx3, ty3));
        }

        // VoronoiFortune generator = VoronoiFortune();
        // generator.triangulate = 0;

        // Line2d[] lllines;
        // generator.onLine = (line){
        //     lllines ~= line;
        // };

        // generator.onVertex = (v){

        // };

        // generator.runVoronoi(points);

        // foreach (i, Line2d l; lines1)
        // {
        //     if(color !in clusters){
        //         clusters[color] = [];
        //     }

        //     clusters[color] ~= l;

        //     if(l.end == clusterStart || l.start == clusterStart){
        //         color = RGBA.random;
        //         clusterStart = l.end;
        //     }

        // }

        // import api.dm.kit.sprites.transitions: SliceTransition;

        // auto st = new SliceTransition!Line2d(15000);
        // st.range = lllines;
        // addCreate(st);

        // st.onValueSlice = (Line2d[] slice){
        //     foreach(lll; slice){
        //         sites ~= lll;
        //     }
        // };

        // st.run;

        createDebugger;
    }

    override void draw()
    {
        super.draw;

        import api.dm.kit.graphics.colors.rgba : RGBA;

        graphics.changeColor(RGBA.red);

        foreach (ref p; points)
        {
            graphics.fillCircle(p.x, p.y, 2);
        }

        graphics.restoreColor;

        graphics.changeColor(RGBA.red);

        // foreach (i, v; vertex)
        // {
        //     if(i == 0){
        //         continue;
        //     }
        //     graphics.line(vertex[i - 1], v);
        // }

        foreach (trig; trigs)
        {
            graphics.line(trig.a, trig.b, RGBA.green);
            graphics.line(trig.b, trig.c, RGBA.green);
            graphics.line(trig.c, trig.a, RGBA.green);
        }

        // foreach(s; sites){
        //     graphics.line(s.start, s.end, RGBA.green);
        // }

        // foreach (color, lines; clusters)
        // {
        //     graphics.changeColor(color);
        //     scope(exit){
        //         graphics.restoreColor;
        //     }
        //     foreach (l; lines)
        //     {
        //         graphics.line(l);
        //     }
        // }

        // foreach (trig; trigs)
        // {
        //     graphics.line(trig.b, trig.c);
        // }

        graphics.restoreColor;
    }
}
