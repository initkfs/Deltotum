module api.dm.gui.controls.indicators.sevsegments.seven_segment;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.math.geom2.rect2 : Rect2d;
import api.math.geom2.vec2 : Vec2d;

import Math = api.math;

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

        double segmentVAngleXOffset = 0;
    }

    double hSegmentWidth = 0;
    double hSegmentHeight = 0;
    double vSegmentWidth = 0;
    double vSegmentHeight = 0;
    double segmentCornerBevel = 0;
    double segmentSpacing = 0;

    double dotDiameter = 0;
    double dotPadding = 0;

    double segmentAngle = 0;

    this(double width = 0, double height = 0)
    {
        this.width = width;
        this.height = height;
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadSevenSegmentTheme;
    }

    void loadSevenSegmentTheme()
    {
        if (width == 0)
        {
            initWidth = theme.controlDefaultHeight / 2;
        }

        if (height == 0)
        {
            initHeight = theme.controlDefaultWidth / 2;
        }

        if (segmentSpacing == 0)
        {
            segmentSpacing = 0;
        }

        if (segmentAngle == 0)
        {
            segmentAngle = 10;
        }

        if (hSegmentWidth == 0)
        {
            hSegmentWidth = width;
        }

        if (hSegmentHeight == 0)
        {
            hSegmentHeight = height * 0.1;
        }

        if (vSegmentWidth == 0)
        {
            vSegmentWidth = hSegmentHeight;
        }

        if (vSegmentHeight == 0)
        {
            vSegmentHeight = hSegmentWidth;
        }

        if (segmentCornerBevel == 0)
        {
            segmentCornerBevel = hSegmentHeight / 2;
        }

        if(dotDiameter == 0){
            dotDiameter = hSegmentHeight * 1.5;
        }
    }

    override void create()
    {
        super.create;

        segmentVAngleXOffset = vSegmentHeight / 2 * Math.cosDeg(segmentAngle);
        
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

        auto rightTop = Vec2d(segmentB.boundsRect.right, segmentB.y);
        auto dw = rightTop.x - x;
        if(dw > width){
            width = dw;
        }

        auto topY = segmentA.y;
        auto dh = boundsRect.bottom - topY;
        if(dh > height){
            height = dh;
        }

        invalidateListeners ~= () { layoutSegments; };
    }

    protected void layoutSegments()
    {
        //auto widthOffset = segmentA.width - segmentVAngleXOffset;

        segmentD.x = x + vSegmentWidth;
        segmentD.y = y + height - segmentD.height;

        segmentE.x = segmentD.x - segmentCornerBevel;
        segmentE.y = segmentD.y - segmentE.height + segmentCornerBevel;

        segmentC.x = segmentD.boundsRect.right- segmentCornerBevel;
        segmentC.y = segmentD.y - segmentC.height + segmentCornerBevel;

        segmentG.x = segmentE.boundsRect.right - segmentCornerBevel;
        segmentG.y = segmentE.y - segmentCornerBevel;

        segmentB.x = segmentG.boundsRect.right- segmentCornerBevel;
        segmentB.y = segmentG.y - segmentB.height + segmentCornerBevel;

        segmentF.x = segmentG.x- segmentCornerBevel;
        segmentF.y = segmentG.y- segmentF.height + segmentCornerBevel;

        segmentA.x = segmentF.boundsRect.right - segmentCornerBevel;
        segmentA.y = segmentF.y- segmentCornerBevel;

        segmentLeftBottomDot.x = segmentD.boundsRect.right + segmentCornerBevel;
        segmentLeftBottomDot.y = segmentD.boundsRect.middleY - segmentLeftBottomDot.halfHeight;
    }

    void setUpSegment(Sprite2d segment)
    {
        segment.isResizedByParent = false;
        segment.isLayoutManaged = false;
        segment.isManaged = false;
        addCreate(segment);

        import api.dm.kit.sprites2d.textures.texture2d : Texture2d;

        if (auto texture = cast(Texture2d) segment)
        {
            texture.bestScaleMode;
        }

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
        const double radius = dotDiameter / 2;

        Rect2d box = Rect2d(0, 0, dotDiameter, dotDiameter).boundingBox(segmentAngle);
        auto segment = createVShapeSegment(box, segmentAngle, dotDiameter / 2, createSegmentStyle);

        return segment;
    }

    protected Sprite2d createHSegment()
    {
        Sprite2d segment = theme.convexPolyShape(hSegmentWidth, hSegmentHeight, angle, segmentCornerBevel, createSegmentStyle);
        return segment;
    }

    protected Sprite2d createVSegment()
    {
        assert(vSegmentWidth > 0);
        assert(vSegmentHeight > 0);

        auto segmentStyle = createSegmentStyle;

        if (!platform.cap.isVectorGraphics)
        {
            return theme.rectShape(vSegmentWidth, vSegmentHeight, segmentAngle, segmentStyle);
        }

        import api.dm.kit.sprites2d.textures.vectors.shapes.vshape2d : VShape;

        Rect2d box = Rect2d(0, 0, vSegmentWidth, vSegmentHeight).boundingBox(segmentAngle);

        auto segment = createVShapeSegment(box, segmentAngle, segmentCornerBevel, segmentStyle);

        return segment;
    }

    protected Sprite2d createVShapeSegment(Rect2d box, double angle, double cornerBevel, GraphicStyle segmentStyle)
    {
        import api.dm.kit.sprites2d.textures.vectors.shapes.vshape2d : VShape;

        auto segment = new class VShape
        {
            this()
            {
                super(box.width, box.height, segmentStyle);
            }

            override void createTextureContent()
            {
                auto ctx = canvas;
                auto thisStyle = segmentStyle;

                auto thisHeight = box.height;
                auto thisWidth = box.width;

                auto halfLineW = thisStyle.lineWidth / 2;

                ctx.translate(thisWidth / 2, thisHeight / 2);
                ctx.rotateRad(Math.degToRad(segmentAngle));

                auto halfW = thisWidth / 2;
                auto halfH = thisHeight / 2;

                ctx.moveTo(0, halfH - halfLineW);
                ctx.lineTo(-cornerBevel, halfH - cornerBevel - halfLineW);
                ctx.lineTo(-cornerBevel, -halfH + cornerBevel + halfLineW);
                ctx.lineTo(0, -halfH + halfLineW);
                ctx.lineTo(cornerBevel, -halfH + cornerBevel + halfLineW);
                ctx.lineTo(cornerBevel, halfH - cornerBevel - halfLineW);
                ctx.lineTo(0, halfH - halfLineW);

                if(thisStyle.isFill){
                    ctx.color = thisStyle.fillColor;
                    ctx.fill;
                }

                ctx.color = thisStyle.lineColor;
                ctx.lineWidth = thisStyle.lineWidth;
                ctx.stroke;
            }
        };

        return segment;
    }

    void reset()
    {
        foreach (segment; segments)
        {
            segment.isVisible = false;
        }

        if(segmentLeftBottomDot && segmentLeftBottomDot.isVisible){
            segmentLeftBottomDot.isVisible = false;
        }
    }

    protected bool showSegment(Sprite2d segment)
    {
        if (!segment)
        {
            return false;
        }
        segment.isVisible = true;
        return true;
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

    bool showSegmentA() => showSegment(segmentA);
    bool showSegmentB() => showSegment(segmentB);
    bool showSegmentC() => showSegment(segmentC);
    bool showSegmentD() => showSegment(segmentD);
    bool showSegmentE() => showSegment(segmentE);
    bool showSegmentF() => showSegment(segmentF);
    bool showSegmentG() => showSegment(segmentG);
    bool showSegmentLeftBottomDot() => showSegment(segmentLeftBottomDot);
}
