module api.dm.addon.math.geom2.clipping;

import api.math.geom2.rect2 : Rect2d;
import api.math.geom2.line2 : Line2d;
import api.math.geom2.vec2 : Vec2d;

/**
 * Authors: initkfs
 */
mixin template ClipUnitTest(bool function(Line2d, Rect2d, out Line2d) clip)
{
    import api.math.geom2.rect2 : Rect2d;
    import api.math.geom2.line2 : Line2d;
    import api.math.geom2.vec2 : Vec2d;

    enum funcType = clip.stringof;

    unittest
    {
        Line2d clipped;

        Rect2d bound1 = {x: 10, y: 10, width: 100, height: 100};

        auto lineAbove = Line2d(9, 9, 110, 9);
        assert(!clip(lineAbove, bound1, clipped), funcType);

        auto lineTop = Line2d(10, 10, 110, 10);
        assert(clip(lineTop, bound1, clipped), funcType);
        assert(lineTop == clipped, funcType);

        auto lineLeftTopToLetfBottom = Line2d(10, 9, 10, 111);
        assert(clip(lineLeftTopToLetfBottom, bound1, clipped), funcType);
        assert(clipped == Line2d(10, 10, 10, 110), funcType);

        auto lineRightTopToRightBottom = Line2d(110, 5, 110, 115);
        assert(clip(lineRightTopToRightBottom, bound1, clipped), funcType);
        assert(clipped == Line2d(110, 10, 110, 110), funcType);

        auto lineLeftBottomToRightBottom = Line2d(5, 110, 115, 110);
        assert(clip(lineLeftBottomToRightBottom, bound1, clipped), funcType);
        assert(clipped == Line2d(10, 110, 110, 110), funcType);

        auto lineLeftTopToRightBottom = Line2d(9, 9, 111, 111);
        assert(clip(lineLeftTopToRightBottom, bound1, clipped), funcType);
        assert(clipped == Line2d(10, 10, 110, 110), funcType);
    }
}

/** 
 * 
 * https://en.wikipedia.org/wiki/Liang–Barsky_algorithm
 */
bool clipLiangBarsky(const Line2d line, const Rect2d bounds, out Line2d clipped)
{
    double x1 = line.start.x;
    double y1 = line.start.y;
    double x2 = line.end.x;
    double y2 = line.end.y;

    double xmin = bounds.x;
    double ymin = bounds.y;
    double xmax = bounds.right;
    double ymax = bounds.bottom;

    double p1 = -(x2 - x1);
    double p2 = -p1;
    double p3 = -(y2 - y1);
    double p4 = -p3;

    double q1 = x1 - xmin;
    double q2 = xmax - x1;
    double q3 = y1 - ymin;
    double q4 = ymax - y1;

    double[5] posarr = 0;
    double[5] negarr = 0;
    int posind = 1, negind = 1;
    posarr[0] = 1;
    negarr[0] = 0;

    if ((p1 == 0 && q1 < 0) || (p2 == 0 && q2 < 0) || (p3 == 0 && q3 < 0) || (p4 == 0 && q4 < 0))
    {
        //parallel
        return false;
    }

    if (p1 != 0)
    {
        double r1 = q1 / p1;
        double r2 = q2 / p2;
        if (p1 < 0)
        {
            negarr[negind++] = r1; // for negative p1, add it to negative array
            posarr[posind++] = r2; // and add p2 to positive array
        }
        else
        {
            negarr[negind++] = r2;
            posarr[posind++] = r1;
        }
    }

    if (p3 != 0)
    {
        double r3 = q3 / p3;
        double r4 = q4 / p4;
        if (p3 < 0)
        {
            negarr[negind++] = r3;
            posarr[posind++] = r4;
        }
        else
        {
            negarr[negind++] = r4;
            posarr[posind++] = r3;
        }
    }

    double maxi(double[] arr, int n)
    {
        double m = 0;
        foreach (i; 0 .. n)
            if (m < arr[i])
                m = arr[i];
        return m;
    }

    double mini(double[] arr, int n)
    {
        double m = 1;
        foreach (i; 0 .. n)
            if (m > arr[i])
                m = arr[i];
        return m;
    }

    double xn1 = 0, yn1 = 0, xn2 = 0, yn2 = 0;
    double rn1 = 0, rn2 = 0;

    rn1 = maxi(negarr, negind); // maximum of negative array
    rn2 = mini(posarr, posind); // minimum of positive array

    if (rn1 > rn2)
    { // reject
        //outside clipping window;
        return false;
    }

    xn1 = x1 + p2 * rn1;
    yn1 = y1 + p4 * rn1; // computing new points

    xn2 = x1 + p2 * rn2;
    yn2 = y1 + p4 * rn2;

    clipped = Line2d(xn1, yn1, xn2, yn2);
    return true;
}

mixin ClipUnitTest!(&clipLiangBarsky);

enum ClipPosCS : ubyte
{
    inside = 0,
    top = 0b1000,
    bottom = 0b0100,
    right = 0b0010,
    left = 0b0001,
}

bool clipCohenSutherland(const Line2d line, const Rect2d bounds, out Line2d clipped)
{
    double xMin = bounds.x;
    double xMax = bounds.right;
    double yMin = bounds.y;
    double yMax = bounds.bottom;

    int checkPointPos(double x, double y)
    {
        int posCode = ClipPosCS.inside;
        if (x < xMin)
            posCode |= ClipPosCS.left;
        else if (x > xMax)
            posCode |= ClipPosCS.right;
        if (y < yMin)
            posCode |= ClipPosCS.bottom;
        else if (y > yMax)
            posCode |= ClipPosCS.top;

        return posCode;
    }

    double x1 = line.start.x;
    double y1 = line.start.y;
    double x2 = line.end.x;
    double y2 = line.end.y;

    int code1 = checkPointPos(x1, y1);
    int code2 = checkPointPos(x2, y2);

    bool isClipped;

    while (true)
    {
        if ((code1 == 0) && (code2 == 0))
        {
            //point inside bounds
            isClipped = true;
            break;
        }
        else if (code1 & code2)
        {
            //point outside bounds
            break;
        }
        else
        {
            int codeOutside;
            double x = 0, y = 0;

            codeOutside = (code1 != 0) ? code1 : code2;

            // Intersection: y = y1 + slope * (x - x1), x = x1 + (1 / slope) * (y - y1)
            if (codeOutside & ClipPosCS.top)
            {
                //above
                x = x1 + (x2 - x1) * (yMax - y1) / (y2 - y1);
                y = yMax;
            }
            else if (codeOutside &  ClipPosCS.bottom)
            {
                // below
                x = x1 + (x2 - x1) * (yMin - y1) / (y2 - y1);
                y = yMin;
            }
            else if (codeOutside & ClipPosCS.right)
            {
                //right
                y = y1 + (y2 - y1) * (xMax - x1) / (x2 - x1);
                x = xMax;
            }
            else if (codeOutside & ClipPosCS.left)
            {
                //left
                y = y1 + (y2 - y1) * (xMin - x1) / (x2 - x1);
                x = xMin;
            }

            //clip
            if (codeOutside == code1)
            {
                x1 = x;
                y1 = y;
                code1 = checkPointPos(x1, y1);
            }
            else
            {
                x2 = x;
                y2 = y;
                code2 = checkPointPos(x2, y2);
            }
        }
    }

    if (isClipped)
    {
        clipped = Line2d(x1, y1, x2, y2);
    }

    return isClipped;
}

mixin ClipUnitTest!(&clipCohenSutherland);
