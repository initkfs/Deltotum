module dm.gui.controls.indicators.gauges.gauge;

import dm.kit.sprites.sprite : Sprite;
import dm.gui.controls.control : Control;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;
import dm.gui.controls.texts.text : Text;
import dm.gui.controls.indicators.seven_segment : SevenSegment;
import dm.gui.containers.hbox : HBox;

import Math = dm.math;

/**
 * Authors: initkfs
 */
class Gauge : Control
{
    protected
    {
        Sprite[] segments;
        Text[] labels;

        Sprite outerFace;
        Sprite innerFace;

        double radius = 0;

        enum segmentPadding = 2;
        double innerPadding = 10;
        double segmentCount = 20;

        double fromAngle = 270;
        double toAngle = 45;

        SevenSegment[] ledSegments;
        HBox ledDisplay;
    }

    this(double radius = 60)
    {
        this.radius = radius;

        const diameter = radius * 2;

        this.width = diameter;
        this.height = diameter;

        import dm.kit.sprites.layouts.center_layout : CenterLayout;

        this.layout = new CenterLayout();
        layout.isAutoResize = true;

        isBorder = false;

        invalidateListeners ~= () { layoutSegments; };
    }

    void layoutSegments()
    {
        double fullAngle = (360 - (360 - fromAngle));
        double angleDt = Math.round(fullAngle / segmentCount);
        import dm.math.vector2 : Vector2;

        double sangle = 45 - angleDt / 2;

        double px = x + width / 2;
        double py = y + height / 2;

        double angle = 45;
        foreach (i, s; segments)
        {
            auto polarCoords = Vector2.fromPolarDeg(angle, radius - innerPadding);
            s.x = px + polarCoords.x - s.width / 2;
            s.y = py + polarCoords.y - s.height / 2;
            angle = Math.round(angle - angleDt);
            s.angle = sangle;
            sangle = Math.round(sangle - angleDt);
        }

        double labelRadius = radius - 30;
        double labelAngleDt = Math.round((360 - 45) / labels.length);
        double labelAnglePos = 135;
        foreach (label; labels)
        {
            auto coords = Vector2.fromPolarDeg(labelAnglePos, labelRadius);
            label.x = px + coords.x - label.width / 2;
            label.y = py + coords.y - label.height / 2;
            labelAnglePos += labelAngleDt;
        }
    }

    override void create()
    {
        super.create;
        double semicircleLength = (2 * Math.PI * (radius - innerPadding)) - Math.degToRad(
            360 - fromAngle);
        semicircleLength -= segmentPadding * segmentCount;

        double segmentWidth = semicircleLength / segmentCount;
        assert(segmentWidth > 0);

        double segmengHeight = segmentWidth;

        auto style = createDefaultStyle(width, height);
        if (!style.isNested)
        {
            style.isFill = true;
            style.color = graphics.theme.colorAccent;
        }

        foreach (i; 0 .. segmentCount)
        {
            import dm.kit.sprites.textures.vectors.shapes.vregular_polygon : VRegularPolygon;

            auto segment = new VRegularPolygon(segmentWidth, segmengHeight, style, 0);
            segment.isLayoutManaged = false;
            segment.isVisible = false;
            addCreate(segment);
            segments ~= segment;
        }

        import dm.kit.sprites.textures.vectors.varc : VArc;

        auto faceStyle = createDefaultStyle(width, height);
        if (!faceStyle.isNested)
        {
            faceStyle.lineWidth = 7;
            faceStyle.isFill = false;
        }

        auto newOuterFace = new VArc(radius, faceStyle);
        newOuterFace.fromAngleRad = (3 * Math.PI) / 4;
        newOuterFace.toAngleRad = (Math.PI) / 4;
        outerFace = newOuterFace;
        addCreate(outerFace);

        auto newInnerFace = new VArc(radius - segmengHeight, faceStyle);
        newInnerFace.fromAngleRad = newOuterFace.fromAngleRad;
        newInnerFace.toAngleRad = newOuterFace.toAngleRad;
        innerFace = newInnerFace;
        addCreate(innerFace);

        foreach (i; 1 .. 8)
        {
            import std.conv : to;

            auto text = new Text(i.to!dstring);
            text.isLayoutManaged = false;
            addCreate(text);
            labels ~= text;
        }

        ledDisplay = new HBox;
        //ledDisplay.isLayoutManaged = false;
        addCreate(ledDisplay);

        double ledWidth = 20;
        double ledHeight = 35;

        foreach (i; 0 .. 2)
        {
            auto segment = new SevenSegment(ledWidth, ledHeight);
            //TODO calculate
            segment.hSegmentWidth = 10;
            segment.hSegmentHeight = 4;
            segment.vSegmentWidth = 4;
            segment.vSegmentHeight = 10;
            segment.segmentCornerBevel = 2;
            ledSegments ~= segment;
            ledDisplay.addCreate(segment);
        }

        layoutSegments;

        selectSegments(4);

        foreach (s; ledSegments)
        {
            s.show0to9(9);
        }
    }

    void reset()
    {
        foreach (s; segments)
        {
            if (s.isVisible)
            {
                s.isVisible = false;
            }
        }
    }

    void selectAll()
    {
        selectSegments(segments.length);
    }

    void selectSegments(size_t count)
    {
        assert(count < segments.length);
        size_t counter;
        foreach_reverse (s; segments)
        {
            s.isVisible = true;
            if (counter >= count)
            {
                break;
            }
            counter++;
        }
    }

}
