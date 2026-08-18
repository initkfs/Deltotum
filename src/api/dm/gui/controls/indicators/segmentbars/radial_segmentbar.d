module api.dm.gui.controls.indicators.segmentbars.radial_segmentbar;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.styles.gstyle : GStyle;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.geom2.vec2 : Vec2f;

import Math = api.math;

class RadialSegmentBar : Control
{
    size_t segmentsCount = 5;

    protected
    {
        Sprite2d[] _segmentsOff;
        Sprite2d[] _segmentsOn;
    }

    GStyle segmentStyleOn;
    GStyle segmentStyleOff;

    float diameter = 0;
    float minAngleDeg = 0;
    float maxAngleDeg = 0;

    float angleOffset = -90;

    bool isUseMiddleAngleOffset;

    this(float diameter = 0, float minAngleDeg = 0, float maxAngleDeg = 180)
    {
        this.diameter = diameter;

        assert(minAngleDeg < maxAngleDeg);
        this.minAngleDeg = minAngleDeg;
        this.maxAngleDeg = maxAngleDeg;
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadRadialSegmentBarTheme;
    }

    void loadRadialSegmentBarTheme()
    {
        if (diameter == 0)
        {
            diameter = theme.meterThumbDiameter;
        }

        assert(diameter > 0);
        initSize(diameter, diameter);

        if (segmentStyleOn == GStyle.init)
        {
            segmentStyleOn = createFillStyle;
            if (!segmentStyleOn.isPreset)
            {
                segmentStyleOn.isFill = false;
                segmentStyleOn.lineColor = segmentStyleOn.fillColor;
                enum minLineWidth = 3;
                if (segmentStyleOn.lineWidth < minLineWidth)
                {
                    segmentStyleOn.lineWidth = minLineWidth;
                }
            }
        }

        segmentStyleOff = segmentStyleOn;
        if (!segmentStyleOff.isPreset)
        {
            segmentStyleOff.lineColor = segmentColorOff(segmentStyleOn.lineColor);
            segmentStyleOff.isFill = false;
            segmentStyleOff.fillColor = segmentStyleOff.lineColor;
        }
    }

    override void create()
    {
        super.create;

        _segmentsOn.reserve(segmentsCount);

        if (platform.cap.isVector)
        {
            import api.dm.kit.sprites2d.textures.vectors.vec_shapes.vec_arc : VecArc;
            import api.dm.kit.sprites2d.textures.vectors.vec_shapes.vec_shape : VecShape;

            const textureWidth = width;
            const textureHeight = height;
            assert(textureWidth > 0);
            assert(textureHeight > 0);

            auto segmentShape = new class VecShape
            {
                this()
                {
                    super(textureWidth, textureHeight, segmentStyleOff);
                }

                override void createContent()
                {
                    auto ctx = canvas;
                    ctx.lineWidth = style.lineWidth;
                    ctx.color = style.lineColor;

                    ctx.translate(radius, radius);
                    Vec2f center = Vec2f(0, 0);

                    auto arcRadius = radius - style.lineWidth / 2;

                    drawSegment((i, startAngleDeg, endAngleDeg, angleOffset) {
                        if (style.isFill)
                        {
                            ctx.beginPath;
                        }

                        ctx.arc(center.x, center.y, arcRadius, Math.degToRad(startAngleDeg), Math.degToRad(
                            endAngleDeg));

                        if (style.isFill)
                        {
                            ctx.closePath;
                            ctx.fillPreserve;
                        }

                        ctx.strokePreserve;
                        return true;
                    });

                    if (style.isFill)
                    {
                        ctx.fill;
                    }

                    ctx.stroke;
                }
            };

            addCreate(segmentShape);

            import api.dm.kit.sprites2d.textures.vectors.vec_shapes.vec_arc : VecArc;

            drawSegment((i, startAngleDeg, endAngleDeg, angleOffset) {

                auto segment = new VecArc(radius, segmentStyleOn);
                segment.xCenter = 0;
                segment.yCenter = 0;
                segment.fromAngleRad = Math.degToRad(startAngleDeg);
                segment.toAngleRad = Math.degToRad(endAngleDeg);
                addCreate(segment);
                segment.isVisible = false;
                _segmentsOn ~= segment;
                return true;
            });
        }
        else
        {
            import api.dm.kit.sprites2d.shapes.rcircle : RCircle;

            _segmentsOff.reserve(segmentsCount);

            auto segmentStyleOff = segmentStyleOn;
            if (!segmentStyleOff.isPreset)
            {
                segmentStyleOff.isFill = false;
            }

            import Math = api.math;

            //const segmentSize = 360 / segmentsCount / 2;
            const segmentSize = diameter * Math.sinDeg(180.0 / segmentsCount) / 2;

            auto fillStyle = segmentStyleOn;
            fillStyle.isFill = true;

            foreach (i; 0 .. segmentsCount)
            {
                auto segment = new RCircle(segmentSize, segmentStyleOff);
                segment.isResizedByParent = false;
                addCreate(segment);
                _segmentsOff ~= segment;

                auto fillSegment = new RCircle(segmentSize, fillStyle);
                fillSegment.isResizedByParent = false;
                addCreate(fillSegment);
                fillSegment.isVisible = false;
                _segmentsOn ~= fillSegment;
            }
        }
    }

    protected RGBA segmentColorOff(RGBA color)
    {
        auto newColor = color.toHSLA;
        newColor.a = 0.1;
        return newColor.toRGBA;
    }

    float segmentAngle() => 360.0 / segmentsCount;
    float segmentAngleMiddleOffset() => segmentAngle / 2;

    void drawSegment(scope bool delegate(size_t i, float startAngleDeg, float endAngleDeg, float angleOffset) onAngleDegContinue)
    {
        assert(onAngleDegContinue);

        float angleDiff = segmentAngle;
        float angleMiddleOffset = isUseMiddleAngleOffset ? angleDiff / 2 : 0;

        foreach (i; 0 .. segmentsCount)
        {
            auto startAngle = angleDiff * i - angleMiddleOffset;
            startAngle += angleOffset;

            auto endAngle = startAngle + angleDiff;

            if (!onAngleDegContinue(i, startAngle, endAngle, angleMiddleOffset))
            {
                break;
            }
        }
    }

    float radius() => diameter / 2;

    override void applyLayout()
    {
        super.applyLayout;

        if (_segmentsOff.length == 0 || _segmentsOn.length == 0)
        {
            return;
        }

        assert(segmentsCount == _segmentsOff.length);
        assert(segmentsCount == _segmentsOn.length);

        const currPos = boundsRect.center;

        drawSegment((size_t i, float startAngleDeg, float endAngleDeg, float angleOffset) {
            auto segmentOff = _segmentsOff[i];
            auto segmentOn = _segmentsOn[i];
            auto angleMiddle = Math.angleDegMiddle(startAngleDeg, endAngleDeg);
            auto polarPos = Vec2f.fromPolarDeg(angleMiddle, radius);

            segmentOff.xy = currPos.add(polarPos)
                .sub(Vec2f(segmentOff.halfWidth, segmentOff.halfHeight));
            segmentOn.xy = currPos.add(polarPos)
                .sub(Vec2f(segmentOn.halfWidth, segmentOn.halfHeight));
            return true;
        });
    }

    void hideSegments()
    {
        foreach (s; _segmentsOn)
        {
            s.isVisible = false;
        }
    }

    void showSegments()
    {
        foreach (s; _segmentsOn)
        {
            s.isVisible = true;
        }
    }

    void showSegments(size_t countFrom1)
    {
        foreach (i, s; _segmentsOn)
        {
            s.isVisible = true;
            if ((i + 1) >= countFrom1)
            {
                break;
            }
        }
    }

    inout(Sprite2d[]) segments() inout
    {
        return _segmentsOn;
    }

    Sprite2d segmentByIndex(size_t v)
    {
        assert(_segmentsOn.length > 0);
        auto index = v % _segmentsOn.length;
        return _segmentsOn[index];
    }

}
