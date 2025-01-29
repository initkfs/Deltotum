module api.dm.gui.controls.indicators.segmentbars.radial_segmentbar;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.geom2.vec2 : Vec2d;

import Math = api.math;

class RadialSegmentBar : Control
{
    size_t segmentsCount = 5;

    protected
    {
        Sprite2d[] _segmentsOff;
        Sprite2d[] _segmentsOn;
    }

    GraphicStyle segmentStyleOn;
    GraphicStyle segmentStyleOff;

    double diameter = 0;
    double minAngleDeg = 0;
    double maxAngleDeg = 0;

    double angleOffset = -90;

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

        if (segmentStyleOn == GraphicStyle.init)
        {
            segmentStyleOn = createFillStyle;
            if(!segmentStyleOn.isPreset){
                segmentStyleOn.isFill = false;
                segmentStyleOn.lineColor = segmentStyleOn.fillColor;
            }
        }
    }

    override void create()
    {
        super.create;

        segmentStyleOff = segmentStyleOn;
        if (!segmentStyleOff.isPreset)
        {
            segmentStyleOff.lineColor = segmentColorOff(segmentStyleOn.lineColor);
            segmentStyleOff.isFill = false;
            segmentStyleOff.fillColor = segmentStyleOff.lineColor;
        }

        _segmentsOn.reserve(segmentsCount);

        if (capGraphics.isVectorGraphics)
        {
            import api.dm.kit.sprites2d.textures.vectors.shapes.varc : VArc;
            import api.dm.kit.sprites2d.textures.vectors.shapes.vshape2d : VShape;

            const textureWidth = width;
            const textureHeight = height;
            assert(textureWidth > 0);
            assert(textureHeight > 0);

            auto segmentShape = new class VShape
            {
                this()
                {
                    super(textureWidth, textureHeight, segmentStyleOff);
                }

                override void createTextureContent()
                {
                    auto ctx = canvas;
                    ctx.lineWidth = style.lineWidth;
                    ctx.color = style.lineColor;

                    ctx.translate(radius, radius);
                    Vec2d center = Vec2d(0, 0);

                    auto arcRadius = radius - style.lineWidth / 2;

                    drawSegment((i, startAngleDeg, endAngleDeg, angleOffset) {
                        if(style.isFill){
                            ctx.beginPath;
                        }
                        
                        ctx.arc(center.x, center.y, arcRadius, Math.degToRad(startAngleDeg), Math.degToRad(
                            endAngleDeg));
                        
                        if(style.isFill){
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

            import api.dm.kit.sprites2d.textures.vectors.shapes.varc : VArc;

            drawSegment((i, startAngleDeg, endAngleDeg, angleOffset) {

                auto segment = new VArc(radius, segmentStyleOn);
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
            import api.dm.kit.sprites2d.shapes.circle : Circle;

            _segmentsOff.reserve(segmentsCount);

            auto segmentStyleOff = segmentStyleOn;
            if (!segmentStyleOff.isPreset)
            {
                segmentStyleOff.isFill = false;
            }

            const segmentSize = 360 / segmentsCount / 2;

            foreach (i; 0 .. segmentsCount)
            {
                auto segment = new Circle(segmentSize, segmentStyleOff);
                segment.isResizedByParent = false;
                addCreate(segment);
                _segmentsOff ~= segment;

                auto fillSegment = new Circle(segmentSize, segmentStyleOn);
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
        newColor.l /= 5;
        return newColor.toRGBA;
    }

    double segmentAngle() => 360.0 / segmentsCount;
    double segmentAngleMiddleOffset() => segmentAngle / 2;

    void drawSegment(scope bool delegate(size_t i, double startAngleDeg, double endAngleDeg, double angleOffset) onAngleDegIsContinue)
    {
        assert(onAngleDegIsContinue);

        double angleDiff = segmentAngle;
        double angleMiddleOffset = angleDiff / 2;

        foreach (i; 0 .. segmentsCount)
        {
            auto startAngle = angleDiff * i - angleMiddleOffset;
            if (startAngle > angleOffset)
            {
                startAngle += angleOffset;
            }
            else
            {
                startAngle = 360 - (angleOffset - startAngle);
            }

            auto endAngle = startAngle + angleDiff;

            if (!onAngleDegIsContinue(i, startAngle, endAngle, angleMiddleOffset))
            {
                break;
            }
        }
    }

    double radius() => diameter / 2;

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

        drawSegment((size_t i, double startAngleDeg, double endAngleDeg, double angleOffset) {
            auto segmentOff = _segmentsOff[i];
            auto segmentOn = _segmentsOn[i];
            auto angleMiddle = Math.angleDegMiddle(startAngleDeg, endAngleDeg);
            auto polarPos = Vec2d.fromPolarDeg(angleMiddle, radius);

            segmentOff.xy = currPos.add(polarPos)
                .subtract(Vec2d(segmentOff.halfWidth, segmentOff.halfHeight));
            segmentOn.xy = currPos.add(polarPos)
                .subtract(Vec2d(segmentOn.halfWidth, segmentOn.halfHeight));
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
