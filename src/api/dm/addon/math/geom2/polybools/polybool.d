module api.dm.addon.math.geom2.polybools.polybool;
/*
 * Authors: initkfs
 */
import api.dm.addon.math.geom2.polybools.segments : Segment, SegmentChainer, SegmentSelector;
import api.dm.addon.math.geom2.polybools.intersectors : SelfIntersecter, NonSelfIntersecter;

import api.dm.addon.math.geom2.polybools.helpers : Epsilon;

/* 
 * D port of https://github.com/Menecats/polybool-java
 * Copyright (c) 2021 Davide Menegatti (@menecats)
 * under MIT License: https://github.com/Menecats/polybool-java/blob/main/LICENSE
 */
class PolyResult
{

    double[][][] regions;
    bool inverted;

    this(double[][][] regions, bool inverted = false)
    {
        this.regions = regions;
        this.inverted = inverted;
    }

    double[][][] getRegions()
    {
        return regions;
    }

    void setRegions(double[][][] regions)
    {
        this.regions = regions;
    }

    bool isInverted()
    {
        return inverted;
    }

    void setInverted(bool inverted)
    {
        this.inverted = inverted;
    }

    bool equal(double[][][] expected, double eps = double.epsilon)
    {
        import std.math.operations : isClose;

        if (expected.length != regions.length)
        {
            return false;
        }

        foreach (i, expectRow; expected)
        {
            auto resultRow = regions[i];

            if (resultRow.length != expectRow.length)
            {
                return false;
            }

            foreach (j, expectPoints; expectRow)
            {
                auto resultPoints = resultRow[j];
                if (expectPoints.length != resultPoints.length)
                {
                    return false;
                }

                foreach (pi, p; expectPoints)
                {
                    auto resultPoint = resultPoints[pi];
                    if (!isClose(resultPoint, p, eps))
                    {
                        return false;
                    }
                }

            }
        }

        return true;
    }
}

Epsilon epsilon()
{
    return new Epsilon;
}

Epsilon epsilon(double epsilon, bool experimental = false)
{
    return new Epsilon(epsilon);
}

double[] point(double x, double y)
{
    return [x, y];
}

double[][] region(double[][] points...)
{
    double[][] reg;
    foreach (double[] p; points)
    {
        reg ~= p;
    }
    return reg;
}

PolyResult polygon(double[][][] regions...)
{
    return polygon(false, regions);
}

PolyResult polygon(bool inverted, double[][][] regions...)
{
    double[][][] reg;
    foreach (double[][] p; regions)
    {
        reg ~= p;
    }

    return new PolyResult(reg, inverted);
}

class Segments
{
    Segment[] segments;
    private bool inverted;

    private this(Segment[] segments, bool inverted)
    {
        this.segments = segments;
        this.inverted = inverted;
    }
}

class Combined
{
    Segment[] combined;
    private bool inverted1;
    private bool inverted2;

    private this(Segment[] combined, bool inverted1, bool inverted2)
    {
        this.combined = combined;
        this.inverted1 = inverted1;
        this.inverted2 = inverted2;
    }
}

// Core API
Segments segments(Epsilon epsilon, PolyResult polygon)
{
    SelfIntersecter i = new SelfIntersecter(epsilon);

    foreach (double[][] region; polygon.getRegions())
    {
        i.addRegion(region);
    }

    return new Segments(
        i.calculate(polygon.isInverted()),
        polygon.isInverted()
    );
}

Combined combine(Epsilon epsilon, Segments segments1, Segments segments2)
{
    NonSelfIntersecter i3 = new NonSelfIntersecter(epsilon);

    return new Combined(
        i3.calculate(
            segments1.segments, segments1.inverted,
            segments2.segments, segments2.inverted
    ),
    segments1.inverted,
    segments2.inverted
    );
}

Segments selectUnion(Combined combined)
{
    return new Segments(
        SegmentSelector.unions(combined.combined),
        combined.inverted1 || combined.inverted2
    );
}

Segments selectIntersect(Combined combined)
{
    return new Segments(
        SegmentSelector.intersect(combined.combined),
        combined.inverted1 && combined.inverted2
    );
}

Segments selectDifference(Combined combined)
{
    return new Segments(
        SegmentSelector.difference(combined.combined),
        combined.inverted1 && !combined.inverted2
    );
}

Segments selectDifferenceRev(Combined combined)
{
    return new Segments(
        SegmentSelector.differenceRev(combined.combined),
        !combined.inverted1 && combined.inverted2
    );
}

Segments selectXor(Combined combined)
{
    return new Segments(
        SegmentSelector.xor(combined.combined),
        combined.inverted1 != combined.inverted2
    );
}

PolyResult polygon(Epsilon epsilon, Segments segments)
{
    auto ch = SegmentChainer.chain(segments.segments, epsilon);
    return new PolyResult(
        ch,
        segments.inverted
    );
}

//  API
private PolyResult operate(Epsilon epsilon, PolyResult poly1, PolyResult poly2, Segments delegate(
        Combined) selector)
{
    Segments seg1 = segments(epsilon, poly1);
    Segments seg2 = segments(epsilon, poly2);
    Combined comb = combine(epsilon, seg1, seg2);
    Segments seg3 = selector(comb);
    return polygon(epsilon, seg3);
}

PolyResult unions(Epsilon epsilon, PolyResult poly1, PolyResult poly2)
{
    return operate(epsilon, poly1, poly2, c => selectUnion(c));
}

PolyResult intersect(Epsilon epsilon, PolyResult poly1, PolyResult poly2)
{
    return operate(epsilon, poly1, poly2, c => selectIntersect(c));
}

PolyResult difference(Epsilon epsilon, PolyResult poly1, PolyResult poly2)
{
    return operate(epsilon, poly1, poly2, c => selectDifference(c));
}

PolyResult differenceRev(Epsilon epsilon, PolyResult poly1, PolyResult poly2)
{
    return operate(epsilon, poly1, poly2, c => selectDifferenceRev(c));
}

PolyResult xor(Epsilon epsilon, PolyResult poly1, PolyResult poly2)
{
    return operate(epsilon, poly1, poly2, c => selectXor(c));
}

unittest
{
    import std.math.operations : isClose;

    Epsilon eps = epsilon;

    PolyResult result = intersect(
        eps,
        polygon(
            region(
            point(50, 50),
            point(150, 150),
            point(190, 50)
        ),
        region(
            point(130, 50),
            point(290, 150),
            point(290, 50)
    )
    ),
    polygon(
        region(
            point(110, 20),
            point(110, 110),
            point(20, 20)
    ),
    region(
        point(130, 170),
        point(130, 20),
        point(260, 20),
        point(260, 170)
    )
    )
    );

    double[][][] expected = [
        [[50.0, 50], [110.0, 50], [110.0, 110]],
        [[178.0, 80], [130.0, 50], [130.0, 130], [150.0, 150]],
        [[178.0, 80], [190.0, 50], [260.0, 50], [260, 131.25]]
    ];

    assert(!result.isInverted);
    assert(result.equal(expected));
}

unittest
{
    import std.math.operations : isClose;

    Epsilon eps = epsilon;

    PolyResult poly1 = polygon(
        region(
            point(52, 53),
            point(72, 53),
            point(52, 70),
    )
    );

    PolyResult poly2 = polygon(
        region(
            point(68, 53),
            point(100, 53),
            point(60, 60),
    )
    );

    PolyResult resultIntersect = intersect(eps, poly1, poly2);

    double[][][] expectedIntersect = [
        [
            [72.0, 53.0], [68.0, 53.0], [60.0, 60.0],
            [64.74074074074073, 59.17037037037037]
        ]
    ];

    assert(!resultIntersect.isInverted);
    assert(resultIntersect.equal(expectedIntersect, 0.0001));

    PolyResult resultUnion = unions(eps, poly1, poly2);

    double[][][] expectedUnion = [
        [
            [100.0, 53.0],
            [52.0, 53.0],
            [52.0, 70.0],
            [64.740740, 59.170370]
        ]
    ];

    assert(!resultUnion.isInverted);
    assert(resultUnion.equal(expectedUnion, 0.0001));

    PolyResult resultDiff = difference(eps, poly1, poly2);

    double[][][] expectedDiff = [
        [
            [68.0, 53.0], [52.0, 53.0], [52.0, 70.0],
            [64.740740, 59.170370], [60.0, 60.0]
        ]
    ];

    assert(!resultDiff.isInverted);
    assert(resultDiff.equal(expectedDiff, 0.0001));

    PolyResult resultDiffRev = differenceRev(eps, poly1, poly2);

    double[][][] expectedDiffRef = [
        [[64.740740, 59.170370], [72.0, 53.0], [100.0, 53.0]]
    ];

    assert(!resultDiffRev.isInverted);
    assert(resultDiffRev.equal(expectedDiffRef, 0.0001));

    PolyResult resultXor = xor(eps, poly1, poly2);

    double[][][] expectedXor = [
        [
            [68.0, 53.0], [52.0, 53.0], [52.0, 70.0],
            [64.740740, 59.170370], [60.0, 60.0]
        ],
        [[64.740740, 59.170370], [72.0, 53.0], [100.0, 53.0]]

    ];

    assert(!resultXor.isInverted);
    assert(resultXor.equal(expectedXor, 0.0001));

}
