module api.dm.gui.controls.indicators.segments.radial_segment_bar;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.math.geom2.vec2 : Vec2d;

import Math = api.math;

class RadialSegmentBar : Control
{

    Sprite2d[] segments;
    Sprite2d[] fillSegments;
    size_t segmentsCount = 5;

    GraphicStyle segmentStyle;

    double diameter = 0;
    double minAngleDeg = 0;
    double maxAngleDeg = 0;

    double angleOffset = 90;

    this(double diameter = 0, double minAngleDeg = 0, double maxAngleDeg = 180)
    {
        this.diameter = diameter;

        assert(minAngleDeg < maxAngleDeg);
        this.minAngleDeg = minAngleDeg;
        this.maxAngleDeg = maxAngleDeg;
    }

    override void loadTheme()
    {
        super.loadTheme;

        if (diameter == 0)
        {
            diameter = theme.meterThumbDiameter;
        }

        assert(diameter > 0);
        _width = diameter;
        _height = diameter;
    }

    override void create()
    {
        super.create;

        auto segmentFillStyle = segmentStyle == GraphicStyle.init ? createStyle : segmentStyle;
        auto segmentStyle = segmentFillStyle;
        if (!segmentStyle.isPreset)
        {
            auto segmentColor = segmentStyle.lineColor.toHSL;
            segmentColor.lightness /= 5;
            segmentStyle.lineColor = segmentColor.toRGBA;
        }

        if (capGraphics.isVectorGraphics)
        {
            import api.dm.kit.sprites2d.textures.vectors.shapes.varc : VArc;
            import api.dm.kit.sprites2d.textures.vectors.shapes.vshape2d : VShape;

            const segmentWidth = width;
            const segmentHeight = height;
            assert(segmentWidth > 0);
            assert(segmentHeight > 0);

            auto segmentShape = new class VShape
            {
                this()
                {
                    super(segmentWidth, segmentHeight, segmentStyle);
                }

                override void createTextureContent()
                {
                    auto ctx = canvas;
                    ctx.lineWidth = style.lineWidth;
                    ctx.color = style.lineColor;

                    ctx.translate(radius, radius);
                    Vec2d center = Vec2d(0, 0);

                    drawSegment((i, startAngleDeg, endAngleDeg) {
                        ctx.beginPath;
                        ctx.arc(0, 0, radius - style.lineWidth / 2, Math.degToRad(startAngleDeg), Math.degToRad(
                            endAngleDeg));
                        ctx.closePath;
                        ctx.strokePreserve;

                        return true;
                    });

                    ctx.stroke;
                }
            };

            addCreate(segmentShape);

            import api.dm.kit.sprites2d.textures.vectors.shapes.varc : VArc;

            drawSegment((i, startAngleDeg, endAngleDeg) {

                auto segment = new VArc(radius, segmentFillStyle);
                segment.xCenter = 0;
                segment.yCenter = 0;
                segment.fromAngleRad = Math.degToRad(startAngleDeg);
                segment.toAngleRad = Math.degToRad(endAngleDeg);
                addCreate(segment);
                segment.isVisible = false;
                segments ~= segment;
                return true;
            });
        }
    }

    void drawSegment(scope bool delegate(size_t i, double startAngleDeg, double endAngleDeg) onAngleDegIsContinue)
    {
        assert(onAngleDegIsContinue);

        double angleDiff = 360 / segmentsCount;
        double angleMiddleOffset = angleDiff / 2;

        foreach (i; 0 .. segmentsCount)
        {
            auto startAngle = angleDiff * i - angleMiddleOffset;
            if (startAngle > angleOffset)
            {
                startAngle -= angleOffset;
            }
            else
            {
                startAngle = 360 - (angleOffset - startAngle);
            }

            auto endAngle = startAngle + angleDiff;

            if (!onAngleDegIsContinue(i, startAngle, endAngle))
            {
                break;
            }
        }
    }

    double radius() => diameter / 2;

    // void layoutChildren()
    // {
    //     assert(segments.length == fillSegments.length);

    //     import api.math.geom2.vec2 : Vec2d;

    //     double radius = diameter / 2 - innerPadding;

    //     const cx = boundsRect.middleX;
    //     const cy = boundsRect.middleY;

    //     double angleRange = Math.abs(endAngleDeg - startAngleDeg);
    //     double angleDt = (360.0 - angleRange) / segments.length;
    //     double angle = startAngleDeg;
    //     foreach (i, s; segments)
    //     {
    //         const coords = Vec2d.fromPolarDeg(angle, radius);

    //         s.x = cx + coords.x - s.width / 2;
    //         s.y = cy + coords.y - s.height / 2;
    //         s.angle = angle;

    //         angle += angleDt;
    //         // if(angle > 360){
    //         //     angle = 0;
    //         // }

    //         auto fillSegment = fillSegments[i];
    //         fillSegment.x = s.x;
    //         fillSegment.y = s.y;
    //         fillSegment.angle = s.angle;
    //     }
    // }

    void hideSegments()
    {
        foreach (s; segments)
        {
            s.isVisible = false;
        }
    }

    void showSegments()
    {
        foreach (s; segments)
        {
            s.isVisible = true;
        }
    }

    Sprite2d segmentByIndex(size_t v)
    {
        assert(segments.length > 0);
        auto index = v % segments.length;
        return segments[index];
    }

}
