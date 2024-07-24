module app.dm.addon.gui.controls.indicators.seven_segment;

import app.dm.kit.sprites.sprite : Sprite;
import app.dm.gui.controls.control : Control;
import app.dm.kit.graphics.styles.graphic_style : GraphicStyle;

/**
 * Authors: initkfs
 * See https://en.wikipedia.org/wiki/Seven-segment_display
 */
class SevenSegment : Control
{
    protected
    {
        Sprite segmentA;
        Sprite segmentB;
        Sprite segmentC;
        Sprite segmentD;
        Sprite segmentE;
        Sprite segmentF;
        Sprite segmentG;
        Sprite segmentLeftBottomDot;

        Sprite[] segments;
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
        segmentA.x = bounds.middleX - segmentA.bounds.halfWidth;
        segmentA.y = bounds.y + padding.top;

        segmentB.x = segmentA.bounds.right - segmentCornerBevel + segmentSpacing;
        segmentB.y = segmentA.bounds.middleY + segmentSpacing;

        segmentC.x = segmentB.bounds.x;
        segmentC.y = segmentB.bounds.bottom + segmentSpacing;

        segmentD.x = segmentC.x + segmentCornerBevel - segmentSpacing - segmentD.width;
        segmentD.y = segmentC.bounds.bottom + segmentSpacing - segmentCornerBevel;

        segmentE.x = segmentD.x - segmentSpacing - segmentE.bounds.halfWidth;
        segmentE.y = segmentD.y + segmentCornerBevel - segmentSpacing - segmentE.height;

        segmentF.x = segmentE.x;
        segmentF.y = segmentE.y - segmentSpacing - segmentF.height;

        segmentG.x = segmentE.bounds.middleX + segmentSpacing;
        segmentG.y = segmentE.y - segmentSpacing / 2 - segmentG.bounds.halfHeight;

        segmentLeftBottomDot.x = segmentC.bounds.right + dotPadding - segmentCornerBevel;
        segmentLeftBottomDot.y = segmentD.bounds.middleY - segmentLeftBottomDot.bounds.halfHeight;
    }

    void setUpSegment(Sprite segment)
    {
        addCreate(segment);
        segments ~= segment;
    }

    Sprite createSegmentA()
    {
        return createHSegment;
    }

    Sprite createSegmentB()
    {
        return createVSegment;
    }

    Sprite createSegmentC()
    {
        return createVSegment;
    }

    Sprite createSegmentD()
    {
        return createHSegment;
    }

    Sprite createSegmentE()
    {
        return createVSegment;
    }

    Sprite createSegmentF()
    {
        return createVSegment;
    }

    Sprite createSegmentG()
    {
        return createHSegment;
    }

    Sprite createDot()
    {
        return createDotSegment;
    }

    protected GraphicStyle createSegmentStyle()
    {
        GraphicStyle style = createDefaultStyle;
        if (!style.isNested)
        {
            style.isFill = true;
            style.lineColor = graphics.theme.colorAccent;
            style.fillColor = style.lineColor;
        }
        return style;
    }

    protected Sprite createDotSegment()
    {
        Sprite segment;
        const double radius = dotDiameter / 2;
        if (capGraphics.isVectorGraphics)
        {
            import app.dm.kit.sprites.textures.vectors.shapes.vcircle : VCircle;

            segment = new VCircle(radius, createSegmentStyle);
        }
        else
        {
            import app.dm.kit.sprites.shapes.circle : Circle;

            segment = new Circle(radius, createSegmentStyle);
        }

        segment.isVisible = false;
        return segment;
    }

    protected Sprite createHSegment()
    {
        Sprite segment;
        if (capGraphics.isVectorGraphics)
        {
            import app.dm.kit.sprites.textures.vectors.shapes.vregular_polygon : VRegularPolygon;

            segment = new VRegularPolygon(hSegmentWidth, hSegmentHeight, createSegmentStyle, segmentCornerBevel);
        }
        else
        {
            import app.dm.kit.sprites.shapes.regular_polygon : RegularPolygon;

            segment = new RegularPolygon(hSegmentWidth, hSegmentHeight, createSegmentStyle, segmentCornerBevel);
        }

        segment.isVisible = false;
        return segment;
    }

    protected Sprite createVSegment()
    {
        Sprite segment;
        if (capGraphics.isVectorGraphics)
        {
            import app.dm.kit.sprites.textures.vectors.shapes.vregular_polygon : VRegularPolygon;

            segment = new VRegularPolygon(vSegmentWidth, vSegmentHeight, createSegmentStyle, segmentCornerBevel);
        }
        else
        {
            import app.dm.kit.sprites.shapes.regular_polygon : RegularPolygon;

            segment = new RegularPolygon(vSegmentWidth, vSegmentHeight, createSegmentStyle, segmentCornerBevel);
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

    protected void showSegment(Sprite segment)
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
