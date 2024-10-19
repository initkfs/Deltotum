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

    Vec2d[] voronoiCells;

    Random rnd;

    Line2d[][RGBA] clusters;
    Vec2d[] clustersLines = [Vec2d(0, 0)];

    Vec2d[][Vec2d] vcells;

    struct VoronoiCell
    {
        import api.math.geom2.polygon2 : Polygon2;

        Vec2d[] points;

        // double massCenter(){
        //     doublex sumX = vertex.x;
        //     double
        //     foreach (Vec2d key; neighbours)
        //     {

        //     }
        // }
    }

    VoronoiCell[] cells;

    override void create()
    {
        super.create;

        rnd = new Random;

        import api.math;

        int ntri = 0;

        enum pCount = 20;
        points = new Vec2d[](pCount);

        foreach (pi; 0 .. pCount)
        {
            auto rx = rnd.randomBetween(0, 500);
            auto ry = rnd.randomBetween(0, 500);
            points[pi] = Vec2d(rx, ry);
        }

        trigs = triangulate(points);

        //TODO more optimal
        foreach (p; points)
        {
            Triangle2d[] allCellTrigs;
            foreach (trig; trigs)
            {
                if (trig.a == p || trig.b == p || trig.c == p)
                {
                    allCellTrigs ~= trig;
                }
            }

            Vec2d[] vcellCenters;
            foreach (cellTrig; allCellTrigs)
            {
                vcellCenters ~= cellTrig.circumcircleCenter;
            }

        }

        // import std.conv: text;
        // assert(polygonTrigs.length == allCellTrigs.length, text(polygonTrigs.length, ":", allCellTrigs.length));

        // vcells[p] = new Vec2d[](polygonTrigs.length);
        // foreach (i, vPolygon; polygonTrigs)
        // {
        //     vcells[p][i] = vPolygon.circumcircleCenter;
        // }
        //}

        //TODO more optimal than 0^2
        foreach (trig; trigs)
        {
            // voronoiCells ~= trig.circumcircleCenter;

            // VoronoiCell cell;
            // cell.vertex = trig.circumcircleCenter;

            // foreach (otherTrig; trigs)
            // {
            //     if (trig == otherTrig)
            //     {
            //         continue;
            //     }

            //     const commonVerts = trig.commonVertices(otherTrig);

            //     if (commonVerts != 0)
            //     {
            //         auto cellCenter = otherTrig.circumcircleCenter;
            //         if (commonVerts > 1)
            //         {
            //             cell.neighbours ~= cellCenter;
            //         }
            //         else
            //         {
            //             cell.adjacents ~= cellCenter;
            //         }
            //     }

            // }

            // cells ~= cell;
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

        foreach (p, cells; vcells)
        {
            graphics.circle(p.x, p.y, 2, RGBA.lightblue);

            graphics.polygon(cells, RGBA.lightcoral);
        }

        // foreach (c; cells)
        // {
        //    auto center = c.vertex;
        //    foreach (cc; c.cell)
        //    {
        //        graphics.line(center, cc, RGBA.lightblue);
        //    }
        // }

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
