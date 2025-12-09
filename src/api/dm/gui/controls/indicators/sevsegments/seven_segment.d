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

        float segmentVAngleXOffset = 0;
    }

    float hSegmentWidth = 0;
    float hSegmentHeight = 0;
    float vSegmentWidth = 0;
    float vSegmentHeight = 0;
    float segmentCornerBevel = 0;
    float segmentSpacing = 0;

    float dotDiameter = 0;
    float dotPadding = 0;

    float segmentAngle = 0;

    this(float width = 0, float height = 0)
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

    Sprite2d createSegmentA() => createHSegment;
    Sprite2d createSegmentB() => createVSegment;
    Sprite2d createSegmentC() => createVSegment;
    Sprite2d createSegmentD() => createHSegment;
    Sprite2d createSegmentE() => createVSegment;
    Sprite2d createSegmentF() => createVSegment;
    Sprite2d createSegmentG() =>  createHSegment;
    Sprite2d createDot() => createDotSegment;

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
        const float size = dotDiameter;

        Rect2d box = Rect2d(0, 0, size, size).boundingBox(segmentAngle);
        auto segment = createVShapeSegment(box, size, size, segmentAngle, size, createSegmentStyle);

        return segment;
    }

    protected Sprite2d createHSegment()
    {
        Rect2d box = Rect2d(0, 0, hSegmentWidth, hSegmentHeight);
        float cornerBevel = segmentCornerBevel;
        return createHShapeSegment(box, cornerBevel, createSegmentStyle);
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

        auto segment = createVShapeSegment(box, vSegmentWidth, vSegmentHeight, segmentAngle, segmentCornerBevel, segmentStyle);

        return segment;
    }

    protected Sprite2d createVShapeSegment(Rect2d box, float w, float h, float angle, float cornerBevel, GraphicStyle segmentStyle)
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

                auto thisHeight = h;
                auto thisWidth = w;

                auto halfLineW = thisStyle.lineWidth / 2;

                ctx.translate(box.width / 2, box.height / 2);
                ctx.rotateRad(Math.degToRad(segmentAngle));

                auto halfW = thisWidth / 2;
                auto halfH = thisHeight / 2;

                ctx.moveTo(0, halfH);
                ctx.lineTo(-cornerBevel, halfH - cornerBevel);
                ctx.lineTo(-cornerBevel, -halfH + cornerBevel);
                ctx.lineTo(0, -halfH);
                ctx.lineTo(cornerBevel, -halfH + cornerBevel);
                ctx.lineTo(cornerBevel, halfH - cornerBevel);
                ctx.lineTo(0, halfH);

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

    protected Sprite2d createHShapeSegment(Rect2d box, float cornerBevel, GraphicStyle segmentStyle)
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

                auto halfW = thisWidth / 2;
                auto halfH = thisHeight / 2;

                ctx.moveTo(0, halfH);
                ctx.lineTo(cornerBevel,  0);
                ctx.lineTo(thisWidth - cornerBevel, 0);
                ctx.lineTo(thisWidth, cornerBevel);
                ctx.lineTo(thisWidth - cornerBevel, thisHeight);
                ctx.lineTo(cornerBevel, thisHeight);
                ctx.lineTo(0, halfH);

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
