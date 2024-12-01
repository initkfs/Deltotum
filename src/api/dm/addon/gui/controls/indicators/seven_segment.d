module api.dm.addon.gui.controls.indicators.seven_segment;

import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 * See https://en.wikipedia.org/wiki/Seven-segment_display
 */
class SevenSegment : Control
{
    protected
    {
        Sprite2d segmentA;
        Sprite2d segmentB;
        Sprite2d segmentC;
        Sprite2d segmentD;
        Sprite2d segmentE;
        Sprite2d segmentF;
        Sprite2d segmentG;
        Sprite2d segmentLeftBottomDot;

        Sprite2d[] segments;
    }

    double hSegmentWidth = 30;
    double hSegmentHeight = 10;
    double vSegmentWidth = 10;
    double vSegmentHeight = 30;
    double segmentCornerBevel = 5;
    double segmentSpacing = 2;

    double dotDiameter = 10;
    double dotPadding = 5;

    this(double width = 70, double height = 85)
    {
        this.width = width;
        this.height = height;
        isBorder = false;
    }

    override void create()
    {
        super.create;

        segmentA = createSegmentA;
        setUpSegment(segmentA);
        segmentB = createSegmentB;
        setUpSegment(segmentB);
        segmentC = createSegmentC;
        setUpSegment(segmentC);
        segmentD = createSegmentD;
        setUpSegment(segmentD);
        segmentE = createSegmentE;
        setUpSegment(segmentE);
        segmentF = createSegmentF;
        setUpSegment(segmentF);
        segmentG = createSegmentG;
        setUpSegment(segmentG);

        segmentLeftBottomDot = createDotSegment;
        setUpSegment(segmentLeftBottomDot);

        layoutSegments;

        invalidateListeners ~= (){
            layoutSegments;
        };
    }

    protected void layoutSegments()
    {
        segmentA.x = boundsRect.middleX - segmentA.boundsRect.halfWidth;
        segmentA.y = boundsRect.y + padding.top;

        segmentB.x = segmentA.boundsRect.right - segmentCornerBevel + segmentSpacing;
        segmentB.y = segmentA.boundsRect.middleY + segmentSpacing;

        segmentC.x = segmentB.boundsRect.x;
        segmentC.y = segmentB.boundsRect.bottom + segmentSpacing;

        segmentD.x = segmentC.x + segmentCornerBevel - segmentSpacing - segmentD.width;
        segmentD.y = segmentC.boundsRect.bottom + segmentSpacing - segmentCornerBevel;

        segmentE.x = segmentD.x - segmentSpacing - segmentE.boundsRect.halfWidth;
        segmentE.y = segmentD.y + segmentCornerBevel - segmentSpacing - segmentE.height;

        segmentF.x = segmentE.x;
        segmentF.y = segmentE.y - segmentSpacing - segmentF.height;

        segmentG.x = segmentE.boundsRect.middleX + segmentSpacing;
        segmentG.y = segmentE.y - segmentSpacing / 2 - segmentG.boundsRect.halfHeight;

        segmentLeftBottomDot.x = segmentC.boundsRect.right + dotPadding - segmentCornerBevel;
        segmentLeftBottomDot.y = segmentD.boundsRect.middleY - segmentLeftBottomDot.boundsRect.halfHeight;
    }

    void setUpSegment(Sprite2d segment)
    {
        addCreate(segment);
        segments ~= segment;
    }

    Sprite2d createSegmentA()
    {
        return createHSegment;
    }

    Sprite2d createSegmentB()
    {
        return createVSegment;
    }

    Sprite2d createSegmentC()
    {
        return createVSegment;
    }

    Sprite2d createSegmentD()
    {
        return createHSegment;
    }

    Sprite2d createSegmentE()
    {
        return createVSegment;
    }

    Sprite2d createSegmentF()
    {
        return createVSegment;
    }

    Sprite2d createSegmentG()
    {
        return createHSegment;
    }

    Sprite2d createDot()
    {
        return createDotSegment;
    }

    protected GraphicStyle createSegmentStyle()
    {
        GraphicStyle style = createStyle;
        if (!style.isNested)
        {
            style.isFill = true;
            style.lineColor = theme.colorAccent;
            style.fillColor = style.lineColor;
        }
        return style;
    }

    protected Sprite2d createDotSegment()
    {
        Sprite2d segment;
        const double radius = dotDiameter / 2;
        if (capGraphics.isVectorGraphics)
        {
            import api.dm.kit.sprites.sprites2d.textures.vectors.shapes.vcircle : VCircle;

            segment = new VCircle(radius, createSegmentStyle);
        }
        else
        {
            import api.dm.kit.sprites.sprites2d.shapes.circle : Circle;

            segment = new Circle(radius, createSegmentStyle);
        }

        segment.isVisible = false;
        return segment;
    }

    protected Sprite2d createHSegment()
    {
        Sprite2d segment;
        if (capGraphics.isVectorGraphics)
        {
            import api.dm.kit.sprites.sprites2d.textures.vectors.shapes.vconvex_polygon : VConvexPolygon;

            segment = new VConvexPolygon(hSegmentWidth, hSegmentHeight, createSegmentStyle, segmentCornerBevel);
        }
        else
        {
            import api.dm.kit.sprites.sprites2d.shapes.convex_polygon : ConvexPolygon;

            segment = new ConvexPolygon(hSegmentWidth, hSegmentHeight, createSegmentStyle, segmentCornerBevel);
        }

        segment.isVisible = false;
        return segment;
    }

    protected Sprite2d createVSegment()
    {
        Sprite2d segment;
        if (capGraphics.isVectorGraphics)
        {
            import api.dm.kit.sprites.sprites2d.textures.vectors.shapes.vconvex_polygon : VConvexPolygon;

            segment = new VConvexPolygon(vSegmentWidth, vSegmentHeight, createSegmentStyle, segmentCornerBevel);
        }
        else
        {
            import api.dm.kit.sprites.sprites2d.shapes.convex_polygon : ConvexPolygon;

            segment = new ConvexPolygon(vSegmentWidth, vSegmentHeight, createSegmentStyle, segmentCornerBevel);
        }

        segment.isVisible = false;
        return segment;
    }

    void reset()
    {
        foreach (segment; segments)
        {
            segment.isVisible = false;
        }
    }

    protected void showSegment(Sprite2d segment)
    {
        segment.isVisible = true;
    }

    void showErr()
    {
        reset;
        showSegmentA;
        showSegmentF;
        showSegmentE;
        showSegmentD;
        showSegmentG;
    }

    void showSegments(Args...)()
    {
        static foreach (s; Args)
        {
            mixin("showSegment", s, ";");
        }
    }

    void show0to9(ubyte value)
    {
        reset;

        if (value > 9)
        {
            showErr;
            logger.error("The number exceeds the indicator's capabilities: ", value);
            return;
        }

        switch (value)
        {
            case 0:
                showSegments!("A", "B", "C", "D", "E", "F")();
                break;
            case 1:
                showSegmentB;
                showSegmentC;
                break;
            case 2:
                showSegments!("A", "B", "D", "E", "G")();
                break;
            case 3:
                showSegments!("A", "B", "C", "D", "G")();
                break;
            case 4:
                showSegments!("B", "C", "F", "G")();
                break;
            case 5:
                showSegments!("A", "C", "D", "F", "G")();
                break;
            case 6:
                showSegments!("A", "C", "D", "E", "F", "G")();
                break;
            case 7:
                showSegments!("A", "B", "C")();
                break;
            case 8:
                showSegments!("A", "B", "C", "D", "E", "F", "G")();
                break;
            case 9:
                showSegments!("A", "B", "C", "D", "F", "G")();
                break;
            default:
                break;
        }
    }

    void showSegmentA() => showSegment(segmentA);
    void showSegmentB() => showSegment(segmentB);
    void showSegmentC() => showSegment(segmentC);
    void showSegmentD() => showSegment(segmentD);
    void showSegmentE() => showSegment(segmentE);
    void showSegmentF() => showSegment(segmentF);
    void showSegmentG() => showSegment(segmentG);
    void showSegmentLeftBottomDot() => showSegment(segmentLeftBottomDot);
}
