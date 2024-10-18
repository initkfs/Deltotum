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

    Vec2d[] points;
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
        points = new Vec2d[](pCount);

        foreach (pi; 0 .. pCount)
        {
            auto rx = rnd.randomBetween(0, 500);
            auto ry = rnd.randomBetween(0, 500);
            points[pi] = Vec2d(rx, ry);
        }


        trigs = triangulate(points);

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
