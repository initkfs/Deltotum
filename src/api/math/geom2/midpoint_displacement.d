module api.math.geom2.midpoint_displacement;

import api.math.geom2.vec2 : Vec2d;
import api.math.geom2.line2 : Line2d;
import api.math.random : Random;

import std;

/**
 * Authors: initkfs
 * Ported from Python code https://bitesofcode.wordpress.com/2016/12/23/landscape-generation-using-midpoint-displacement/ 
 * Juan Gallostra Acín, under MIT license https://github.com/juangallostra/Landscape-generator?tab=MIT-1-ov-file
 */
struct MidpointDisplacement
{

    Random rnd;

    Vec2d[] midpointDisplacement(
        Vec2d start,
        Vec2d end,
        double roughness,
        double verticalDisplacement,
        size_t iterationCount = 16,
        bool isVerticalDisplacementVariance = true,
    )
    {

        rnd = new Random;

        if (verticalDisplacement == 0)
        {
            verticalDisplacement = (start[1] + end[1]) / 2;
        }

        Vec2d[] points = [start, end];

        size_t iteration = 1;
        while (iteration <= iterationCount)
        {
            Vec2d[] points_tup = points.dup;
            foreach (i; 0 .. (points_tup.length) - 1)
            {
                import std;

                Vec2d midpoint;

                auto mx = ((points_tup[i]).x + (points_tup[i + 1]).x) / 2.0;
                auto my = ((points_tup[i]).y + (points_tup[i + 1]).y) / 2.0;

                midpoint.x = mx;
                midpoint.y = my;

                double yDisplacement = 0;
                if (isVerticalDisplacementVariance)
                {
                    auto rndDisp = rnd.randomElement([
                        -verticalDisplacement, verticalDisplacement
                    ]);
                    assert(!rndDisp.isNull);
                    yDisplacement = rndDisp.get;
                }
                else
                {
                    yDisplacement = verticalDisplacement;
                }

                midpoint.y += yDisplacement;

                import std : sort;
                import std.array : insertInPlace;

                //TODO more optimal
                points.sort!((p1, p2) => p1.x < p2.x);
                size_t pos;
                foreach (ii, p; points)
                {
                    if (p.x >= midpoint.x)
                    {
                        pos = ii;
                        break;
                    }
                }
                points.insertInPlace(pos, midpoint);
            }

            verticalDisplacement *= (2 ^^ (-roughness));
            iteration++;
        }

        return points;
    }

    Line2d[] landscape(Vec2d[][] layers, double width, double height)
    {
        Line2d[] lines;

        import api.dm.kit.graphics.colors.rgba : RGBA;

        RGBA[int] colors = [
            0: RGBA(195, 157, 224),
            1: RGBA(158, 98, 204),
            2: RGBA(130, 79, 138),
            3: RGBA(68, 28, 99),
            4: RGBA(49, 7, 82),
            5: RGBA(23, 3, 38),
            6: RGBA(240, 203, 163),
        ];

        Vec2d[][] final_layers;

        foreach (Vec2d[] layer; layers)
        {
            Vec2d[] sampled_layer = [];

            foreach (i; 0 .. (layer.length - 1))
            {
                Vec2d p = layer[i];
                sampled_layer ~= p;

                if (((layer[i + 1]).x - (layer[i]).x) > 1)
                {
                    auto m = ((layer[i + 1]).y - (layer[i]).y) / ((layer[i + 1]).x - (layer[i]).x);
                    auto n = (layer[i]).y - m * (layer[i]).x;
                    auto r = (double x) => m * x + n;
                    foreach (j; (cast(int)((layer[i]).x + 1)) .. (cast(int)((layer[i + 1]).x)))
                    {
                        sampled_layer ~= Vec2d(j, r(j));
                    }
                }
            }

            final_layers ~= sampled_layer;

            foreach (Vec2d[] final_layer; final_layers)
            {
                foreach (x; 0 .. (final_layer.length - 1))
                {
                    auto x1 = (final_layer[x]).x;
                    auto y1 = height - (final_layer[x]).y;
                    auto x2 = (final_layer[x]).x;
                    auto y2 = height;

                    lines ~= Line2d(x1, y1, x2, y2);
                }
            }
        }

        return lines;
    }

    Line2d[] generate(
        Vec2d start, 
        Vec2d end, 
        double terrainWidth, 
        double terrainHeight, 
        double roughness = 1.0,
        double verticalDisplacement = 10,
        size_t iterationCount = 10,
        bool isVerticalDisplacementVariance = true)
    {
        auto layer1 = midpointDisplacement(start, end, roughness, verticalDisplacement, iterationCount, isVerticalDisplacementVariance);
        auto lines = landscape([layer1], terrainHeight, terrainHeight);
        
        // auto layer_1 = midpointDisplacement(Vec2d(250, 0), Vec2d(width, 200), 1.4, 20, 12);
        // auto layer_2 = midpointDisplacement(Vec2d(0, 180), Vec2d(width, 80), 1.2, 30, 12);
        // auto layer_3 = midpointDisplacement(Vec2d(0, 270), Vec2d(width, 190), 1, 120, 9);
        // auto layer_4 = midpointDisplacement(Vec2d(0, 350), Vec2d(width, 320), 0.9, 250, 8);

        return lines;
    }
}

unittest
{
    auto gen = MidpointDisplacement();

    double eps = 0.0000001;

    Vec2d[] resDisp1 = [
        {x: 100.0000000000, y: 0.0000000000},
        {x: 125.0000000000, y: 13.1687068560},
        {x: 150.0000000000, y: 24.1610373038},
        {x: 175.0000000000, y: 34.4579982723},
        {x: 200.0000000000, y: 42.5785828326},
        {x: 225.0000000000, y: 51.9579982723},
        {x: 250.0000000000, y: 59.1610373038},
        {x: 275.0000000000, y: 65.6687068560},
        {x: 300.0000000000, y: 70.0000000000},
        {x: 325.0000000000, y: 78.1687068560},
        {x: 350.0000000000, y: 84.1610373038},
        {x: 375.0000000000, y: 89.4579982723},
        {x: 400.0000000000, y: 92.5785828326},
        {x: 425.0000000000, y: 96.9579982723},
        {x: 450.0000000000, y: 99.1610373038},
        {x: 475.0000000000, y: 100.6687068560},
        {x: 500.0000000000, y: 100.0000000000}
    ];

    import std.math.operations : isClose;
    import std.conv : to;

    auto res1 = gen.midpointDisplacement(Vec2d(100, 0), Vec2d(500, 100), 1.4, 20, 4, false);
    assert(res1.length == resDisp1.length);
    foreach (i, received; res1)
    {
        auto expected = resDisp1[i];
        if (!isClose(received.x, expected.x, eps))
        {
            assert(false, [received, expected].to!string);
        }

        if (!isClose(received.y, expected.y, eps))
        {
            assert(false, [received, expected].to!string);
        }
    }

    auto lines = gen.landscape([res1], 500, 500);
    
    assert(lines.length == 399);

    double[][] expected10Lines = [
        [100.0, 500, 100, 500],
        [101, 499.47325172575984, 101, 500],
        [102, 498.9465034515197, 102, 500],
        [103, 498.41975517727946, 103, 500],
        [104, 497.8930069030393, 104, 500],
        [105, 497.36625862879913, 105, 500],
        [106, 496.8395103545589, 106, 500],
        [107, 496.31276208031875, 107, 500],
        [108, 495.7860138060786, 108, 500],
        [109, 495.2592655318384, 109, 500]
    ];

    double leps = 0.0000001;

    auto received10Slice = lines[0..10];
    foreach (i, line; received10Slice)
    {
        auto expectedLine = expected10Lines[i];
        assert(isClose(line.start.x, expectedLine[0], leps));
        assert(isClose(line.start.y, expectedLine[1], leps));
        assert(isClose(line.end.x, expectedLine[2], leps));
        assert(isClose(line.end.y, expectedLine[3], leps));
    }

    auto expectedLast10Lines = [
        [489, 399.70576898335804, 489, 500], 
        [490, 399.7325172575982, 490, 500], 
        [491, 399.7592655318384, 491, 500], 
        [492, 399.7860138060786, 492, 500], 
        [493, 399.81276208031875, 493, 500], 
        [494, 399.8395103545589, 494, 500], 
        [495, 399.86625862879913, 495, 500], 
        [496, 399.8930069030393, 496, 500], 
        [497, 399.91975517727946, 497, 500], 
        [498, 399.9465034515197, 498, 500]];

    auto receivedLast10Slice = lines[$ - 10..$];
    foreach (i, line; receivedLast10Slice)
    {
        auto expectedLine = expectedLast10Lines[i];
        assert(isClose(line.start.x, expectedLine[0], leps));
        assert(isClose(line.start.y, expectedLine[1], leps));
        assert(isClose(line.end.x, expectedLine[2], leps));
        assert(isClose(line.end.y, expectedLine[3], leps));
    }
}
