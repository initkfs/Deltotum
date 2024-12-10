module api.dm.gui.controls.indicators.segments.radial_segment_bar;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

import Math = api.math;

class RadialSegmentBar : Control
{

    Sprite2d[] segments;
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

        double radius = diameter / 2;

        if (capGraphics.isVectorGraphics)
        {
            import api.dm.kit.sprites.sprites2d.textures.vectors.shapes.varc : VArc;

            auto style = segmentStyle == GraphicStyle.init ? createFillStyle : segmentStyle;

            double angleDiff = 360 / segmentsCount;
            double angleMiddleOffset = angleDiff / 2;

            foreach (i; 0 .. segmentsCount)
            {
                auto segment = new VArc(radius, style);

                segment.xCenter = 0;
                segment.yCenter = 0;
                auto stAngle = angleDiff * i - angleMiddleOffset;
                if(stAngle > angleOffset){
                    stAngle -= angleOffset;
                }else {
                    stAngle = 360 - (angleOffset - stAngle);
                }

                auto endAngle = stAngle + angleDiff;
                segment.fromAngleRad = Math.degToRad(stAngle);
                segment.toAngleRad = Math.degToRad(endAngle);
                addCreate(segment);
                segment.isVisible = false;
                segments ~= segment;
            }
        }
    }

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
