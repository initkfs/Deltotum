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
    Line2d[] sites;
    double[][] matrix;

    import api.math.geom2.diamond_square;
    import api.math.geom2.midpoint_displacement: MDLandscapeGenerator;

    MDLandscapeGenerator generator;

    TerrainPixel[] terrain;
    import api.math.geom2.rect2: Rect2d;
    import api.dm.kit.graphics.colors.rgba: RGBA;
    
    Rect2d[][RGBA] terrainPoints;
    Vec2d[] dLines;

    override void create()
    {
        super.create;

        import api.math;

        // int nv = 30;
        // int ntri = 0;

        // points = new Vec2d[](nv + 3);

        // import api.math.random: Random;

        // auto rnd = new Random;

        // for (int i = 0; i < points.length; i++)
        // {
        //     auto x = rnd.randomBetween!int(0, window.width);
        //     auto y = rnd.randomBetween!int(0, window.height);
        //     points[i] = Vec2d(x, y);
        // }

        //  import std;

        // points.sort!((p1, p2) => p1.x < p2.x);

        // trigs = triangulate(points);

        // import api.math.geom2.voronoi.voronoi;

        // import api.math.random: Random;

        // auto rnd = new Random;

        // points = new Vec2d[](100);

        // onLine = (l){
        //     sites ~= l;
        // };

        // foreach (pi; 0..100)
        // {
        //     Vec2d p;
        //     p.x = rnd.randomBetween(0, 400);
        //     p.y = rnd.randomBetween(0, 400);

        //     points[pi] = p;
        // }

        // runVoronoi(points);

        // generator = DiamondSquareTerrain(0, 10);
        // generator.generate;

        // terrain = new TerrainPixel[](generator.terrainSize);
        
        // generator.iterateTerrain((terrainInfo, i) {
        //     auto color = terrainInfo.terrain.color.toRGBA;
        //     (terrainPoints[color]) ~= Rect2d(terrainInfo.x, terrainInfo.y, terrainInfo.pixelWidth, terrainInfo.pixelHeight);
            
        //     terrain[i] = terrainInfo;
        //     return true;
        // });

        // import api.dm.gui.containers.stack_box : StackBox;
        // import api.dm.gui.controls.popups.pointer_popup : PointerPopup;

        // auto sw = generator.canvasWidth;
        // auto box = new StackBox;
        // box.width = sw;
        // box.height = sw;
        // box.isDrawBounds = true;
        // addCreate(box);

        // auto popup = new PointerPopup();
        // box.addCreate(popup);

        // box.onPointerMove ~= (ref e) {
        //     auto ex = e.x;
        //     auto ey = e.y;
        //     auto dx = 1;
        //     auto dy = 1;
        //     foreach (TerrainPixel px; terrain)
        //     {
        //         if (Math.abs(ex - px.x) <= dx && Math.abs(ey - px.y) <= dy)
        //         {
        //             auto text = px.terrain.type.name;
        //             popup.text = text;
        //             popup.show;
        //             break;
        //         }
        //     }
        // };

        generator = new MDLandscapeGenerator(600, 400);
        addCreate(generator);

       
        createDebugger;
    }

    override void draw()
    {
        super.draw;

        import api.dm.kit.graphics.colors.rgba : RGBA;

        // foreach (color, rects; terrainPoints)
        // {
        //     graphics.fillRects(rects, color);
        // }

        // foreach (TerrainPixel terr; terrain)
        // {
        //     graphics.fillRect(Vec2d(terr.x, terr.y), terr.pixelWidth, terr.pixelHeight, terr
        //             .terrain.color.toRGBA);
        // }

        // graphics.setColor(RGBA.red);
        // scope(exit){
        //     graphics.restoreColor;        
        // }

        // foreach (p; points)
        // {
        //     graphics.circle(p.x, p.y, 5, RGBA.red);
        // }

        // foreach (s; sites)
        // {
        //     graphics.line(s.start.x, s.start.y, s.end.x, s.end.y, RGBA.green);
        // }

        // foreach (Triangle2d trig; trigs)
        // {
        //     graphics.line(trig.a, trig.b);
        //     graphics.line(trig.b ,trig.c);
        //     graphics.line(trig.c, trig.a);
        // }
    }
}
