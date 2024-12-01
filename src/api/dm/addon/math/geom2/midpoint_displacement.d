module api.dm.addon.math.geom2.midpoint_displacement;

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

    bool isVertexOnly;

    Line2d[] lines;
    Vec2d[] linePoints;

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

        import std : sort;

        points.sort!((p1, p2) => p1.x < p2.x);

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
                    auto rndDisp = rnd.any([
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

                import std.array : insertInPlace;

                //TODO more optimal, std.range.SortedRange
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

    void landscape(Vec2d[][] layers, double width, double height)
    {
        //TODO reuse
        lines = [];
        linePoints = [];

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

                if (!isVertexOnly)
                {
                    if (((layer[i + 1]).x - (layer[i]).x) > 1)
                    {
                        auto m = ((layer[i + 1]).y - (layer[i]).y) / ((layer[i + 1]).x - (layer[i])
                                .x);
                        auto n = (layer[i]).y - m * (layer[i]).x;
                        auto r = (double x) => m * x + n;
                        foreach (j; (cast(int)((layer[i]).x + 1)) .. (cast(int)((layer[i + 1]).x)))
                        {
                            sampled_layer ~= Vec2d(j, r(j));
                        }
                    }
                }
            }

            final_layers ~= sampled_layer;

            foreach (Vec2d[] final_layer; final_layers)
            {
                foreach (x; 0 .. (final_layer.length - 1))
                {
                    if (isVertexOnly)
                    {
                        linePoints ~= Vec2d((final_layer[x]).x, (final_layer[x]).y);
                    }
                    else
                    {
                        auto x1 = (final_layer[x]).x;
                        auto y1 = height - (final_layer[x]).y;
                        auto x2 = (final_layer[x]).x;
                        auto y2 = height;

                        //TODO y != 0
                        if (y1 <= 0 || y2 <= 0)
                        {
                            continue;
                        }

                        lines ~= Line2d(x1, y1, x2, y2);
                    }

                }
            }
        }
    }

    void generate(
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
        landscape([layer1], terrainHeight, terrainHeight);
        // auto layer_1 = midpointDisplacement(Vec2d(250, 0), Vec2d(width, 200), 1.4, 20, 12);
        // auto layer_2 = midpointDisplacement(Vec2d(0, 180), Vec2d(width, 80), 1.2, 30, 12);
        // auto layer_3 = midpointDisplacement(Vec2d(0, 270), Vec2d(width, 190), 1, 120, 9);
        // auto layer_4 = midpointDisplacement(Vec2d(0, 350), Vec2d(width, 320), 0.9, 250, 8);
    }
}

import api.dm.gui.controls.control : Control;

class MDLandscapeGenerator : Control
{
    import api.dm.gui.controls.forms.fields.regulate_text_field : RegulateTextField;
    import api.dm.gui.controls.forms.fields.regulate_text_panel : RegulateTextPanel;
    import api.dm.gui.containers.container : Container;
    import api.dm.gui.containers.stack_box : StackBox;
    import api.dm.kit.graphics.colors.rgba : RGBA;
    import api.math.geom2.rect2 : Rect2d;
    import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;
    import api.dm.kit.sprites.sprites2d.textures.vectors.vector_texture : VectorTexture;

    StackBox contentContainer;
    double canvasWidth = 0;
    double canvasHeight = 0;

    VectorTexture background;

    Random rnd;

    Vec2d[][RGBA] linePoints;
    Vec2d[][RGBA] layerLinePoints;

    MidpointDisplacement generator;

    double roughnessMin = 0.8;
    double roughnessMax = 1.5;
    double verticalDispMin = 20;
    double verticalDispMax = 250;
    size_t iterationCountMin = 3;
    size_t iterationCountMax = 12;

    RegulateTextField roughnessMinField;
    RegulateTextField roughnessMaxField;
    RegulateTextField verticalMinDispField;
    RegulateTextField verticalMaxDispField;
    RegulateTextField iterationCountMinField;
    RegulateTextField iterationCountMaxField;

    Vec2d start;
    Vec2d end;

    size_t layers = 3;

    RGBA[] colorPalette;
    RGBA[] lightColorPalette;
    RGBA[] backgroundColorPalette;

    BackgroundImage backgroundImage;

    static class BackgroundImage : VectorTexture
    {
        import Math = api.math;

        RGBA lightColor;
        RGBA starColor = RGBA.lightblue;
        RGBA mainColor;

        Vec2d[][RGBA] layerLinePoints;

        Random rnd;

        this(double canvasWidth, double canvasHeight, Random rnd)
        {
            super(canvasWidth, canvasHeight);
            this.rnd = rnd;
        }

        override void createTextureContent()
        {
            super.createTextureContent;
            auto ctx = canvas;

            import api.dm.kit.graphics.contexts.graphics_context : GradientStopPoint;
            import api.dm.kit.graphics.colors.hsv : HSV;

            auto mainColorHSV = mainColor.toHSV;
            auto endColor = mainColorHSV;

            mainColorHSV.value= 0.25;
            endColor.hue = HSV.maxHue - mainColorHSV.hue;
            endColor.value = 1.0;
            endColor.saturation = 1.0;

            GradientStopPoint[] points = [
                {0, mainColorHSV.toRGBA},
                {1, endColor.toRGBA}
            ];

            ctx.linearGradient(Vec2d(0, 0), Vec2d(0, height), points, () {
                ctx.fillRect(0, 0, width, height);
            });

            ctx.color = starColor;

            auto starsCount = rnd.between(10, 30);
            foreach (sc; 0 .. starsCount)
            {
                auto starDiameter = rnd.between(2, 5);
                auto sx = rnd.between(starDiameter, width - starDiameter);
                auto sy = rnd.between(starDiameter, height / 2);
                ctx.arc(sx, sy, starDiameter / 2.0, 0, Math.PI2);
                ctx.fill;
            }

            auto lightDiameter = 100;

            auto lightColorHSV = lightColor.toHSV;
            auto innerLightColor = lightColorHSV;
            auto outerLightColor = lightColorHSV;

            outerLightColor.value = 1;
            outerLightColor.saturation = 1;
            
            //innerLightColor.value = 0.88;

            GradientStopPoint[] lightPoints = [
                {0, outerLightColor.toRGBA},
                {1, innerLightColor.toRGBA}
            ];

            auto lightRadius = lightDiameter / 2;

            auto randomX = rnd.between(lightDiameter, width - lightDiameter);
            auto randomY = rnd.between(lightDiameter + 10, lightDiameter * 3);

            ctx.color = lightColor;
            ctx.arc(randomX, randomY, lightDiameter / 2, 0, Math.PI2);

            ctx.radialGradient(Vec2d(randomX, randomY), Vec2d(randomX, randomY), lightRadius / 4, lightRadius, lightPoints, () {
                ctx.fill;
            });

            foreach (ref color, linePoints; layerLinePoints)
            {
                auto startLineColor = color.toHSV;
                auto endLineColor = startLineColor;

                startLineColor.value = 1;
                endLineColor.value = 0.25;

                double maxY = 0;
                foreach (ref p; linePoints)
                {
                    if (p.y > maxY && p.y < height)
                    {
                        maxY = p.y;
                    }
                }

                GradientStopPoint[2] lineStops = [
                    {0, startLineColor.toRGBA},
                    {1, endLineColor.toRGBA}
                ];

                ctx.color = color;

                auto first = linePoints[0];
                first.y = height - first.y;
                ctx.moveTo(0, height);
                ctx.lineTo(first);

                foreach (p; linePoints)
                {
                    Vec2d point = p;
                    point.y = height - point.y;

                    if (point.x > width)
                    {
                        point.x = width;
                    }
                    if (point.y > height)
                    {
                        point.y = height;
                    }

                    ctx.lineTo(point);
                }

                ctx.lineTo(width, height);
                ctx.lineTo(0, height);
               
                ctx.linearGradient(Vec2d(0, height - maxY), Vec2d(0, height), lineStops, () {
                   ctx.fill;
                });
            }
        }
    }

    this(double canvasWidth = 400, double canvasHeight = 400)
    {
        this.canvasWidth = canvasWidth;
        this.canvasHeight = canvasHeight;

        rnd = new Random;

        import api.dm.kit.sprites.sprites2d.layouts.hlayout : HLayout;

        layout = new HLayout(5);
        layout.isAlignY = true;
        layout.isAutoResize = true;
        isDrawBounds = true;
    }

    override void drawContent()
    {
        super.drawContent;

        // graphics.setClip(Rect2d(x, y, canvasWidth, canvasHeight));
        // scope (exit)
        // {
        //     graphics.removeClip;
        // }

        // foreach (ref color, linePoints; layerLinePoints)
        // {
        //     graphics.polygon(linePoints, linePoints.length - 2, color);
        // }
    }

    override void create()
    {
        super.create;

        generator = MidpointDisplacement();
        generator.isVertexOnly = true;

        contentContainer = new StackBox;
        contentContainer.resize(canvasWidth, canvasHeight);
        addCreate(contentContainer);

        backgroundImage = new BackgroundImage(canvasWidth, canvasHeight, rnd);

        contentContainer.addCreate(backgroundImage);
        contentContainer.isDrawAfterParent = false;

        start = Vec2d(0, 35);
        end = Vec2d(canvasWidth, 45);

        if (colorPalette.length == 0)
        {
            colorPalette = [
                RGBA.web("#9FB8C9"),
                RGBA.web("#87B41D"),
                RGBA.web("#B1D8D5"),
                RGBA.web("#73B8F4"),
                RGBA.web("#8FCF59"),
                RGBA.web("#E9A29A"),
                RGBA.web("#E6AD62"),
                RGBA.web("#259889"),
                RGBA.web("#044F59"),
            ];
        }

        if (backgroundColorPalette.length == 0)
        {
            backgroundColorPalette = [
                //dark
                RGBA.web("#132D50"),
                RGBA.web("#373475"),
                RGBA.web("#2268B1"),
                RGBA.web("#295E67"),
                RGBA.web("#7A344B"),
                RGBA.web("#4C397F"),
            ];
        }

        if (lightColorPalette.length == 0)
        {
            lightColorPalette = [
                RGBA.web("#F4F7F7"),
                RGBA.web("#C2F6F6"),
                RGBA.web("#E2C892"),
                RGBA.web("#EDE870"),
                RGBA.web("#D7E9F7"),
                RGBA.web("#F0E191"),
            ];
        }

        auto fieldRoot = new RegulateTextPanel(5);
        addCreate(fieldRoot);

        auto rMin = 0;
        auto rMax = 5;

        roughnessMinField = createRegField(fieldRoot, "Rough min:", rMin, rMax, (v) {
            roughnessMin = v;
            generate;
        });

        roughnessMinField.value = roughnessMin;

        roughnessMaxField = createRegField(fieldRoot, "Rough max:", rMin, rMax, (v) {
            roughnessMax = v;
            generate;
        });

        roughnessMaxField.value = roughnessMax;

        auto rDispMin = 0;
        auto rDispMax = canvasHeight;

        verticalMinDispField = createRegField(fieldRoot, "Vdisp min:", rDispMin, rDispMax, (
                v) { verticalDispMin = v; generate; });

        verticalMinDispField.value = verticalDispMin;

        verticalMaxDispField = createRegField(fieldRoot, "Vdisp max:", rDispMin, rDispMax, (
                v) { verticalDispMax = v; generate; });

        verticalMaxDispField.value = verticalDispMax;

        auto iterMin = 1;
        auto iterMax = 15;

        iterationCountMinField = createRegField(fieldRoot, "Iter min:", iterMin, iterMax, (
                v) { iterationCountMin = cast(size_t) v; generate; });

        iterationCountMinField.value = iterationCountMin;

        iterationCountMaxField = createRegField(fieldRoot, "Iter max:", iterMin, iterMax, (
                v) { iterationCountMax = cast(size_t) v; generate; });

        iterationCountMaxField.value = iterationCountMax;

        generate;

        foreach (ch; layout.childrenForLayout(this))
        {
            import std;

            writeln(ch.toString, "\n");
        }
    }

    protected RegulateTextField createRegField(Sprite2d root, dstring label = "Label", double minValue = 0, double maxValue = 1, void delegate(
            double) onScrollValue = null)
    {

        auto field = new RegulateTextField;
        root.addCreate(field);
        field.labelField.text = label;
        field.scrollField.minValue = minValue;
        field.scrollField.maxValue = maxValue;
        field.scrollField.onValue ~= onScrollValue;
        return field;
    }

    void generate()
    {
        rnd.shuffle(colorPalette);

        foreach (li; 0 .. layers)
        {
            //auto rndMin = rnd.betweenVec(minStart, maxStart);
            //auto rndMax = rnd.betweenVec(minEnd, maxEnd);
            auto roughness = rnd.between(roughnessMin, roughnessMax);
            auto vdisp = rnd.between(verticalDispMin, verticalDispMax);
            auto iters = rnd.between(iterationCountMin, iterationCountMax);

            //TODO if RGBA.random == colorPaletter[li]
            RGBA color = li < colorPalette.length ? colorPalette[li] : RGBA.random;

            generator.generate(start, end, canvasWidth, canvasHeight, roughness, vdisp, iters, true);

            if (auto colorPtr = color in layerLinePoints)
            {
                    (*colorPtr) = [];
                    //(*colorPtr).reserve(lines.length * 2);
            }
            else
            {
                layerLinePoints[color] = [];
            }

            if (!generator.isVertexOnly)
            {
                foreach (line; generator.lines)
                {
                    layerLinePoints[color] ~= line.start;
                    layerLinePoints[color] ~= line.end;
                }
            }else {
                layerLinePoints[color] = generator.linePoints;
            }
        }

        backgroundImage.layerLinePoints = layerLinePoints;
        backgroundImage.mainColor = rnd.any(backgroundColorPalette).get;
        backgroundImage.lightColor = rnd.any(lightColorPalette).get;
        RGBA starColor = rnd.any(lightColorPalette).get;
        while (starColor == backgroundImage.lightColor)
        {
            starColor = rnd.any(lightColorPalette).get;
        }
        backgroundImage.starColor = starColor;

        backgroundImage.recreate;
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

    gen.landscape([res1], 500, 500);
    auto lines = gen.lines;

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

    auto received10Slice = lines[0 .. 10];
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
        [498, 399.9465034515197, 498, 500]
    ];

    auto receivedLast10Slice = lines[$ - 10 .. $];
    foreach (i, line; receivedLast10Slice)
    {
        auto expectedLine = expectedLast10Lines[i];
        assert(isClose(line.start.x, expectedLine[0], leps));
        assert(isClose(line.start.y, expectedLine[1], leps));
        assert(isClose(line.end.x, expectedLine[2], leps));
        assert(isClose(line.end.y, expectedLine[3], leps));
    }
}
