module api.dm.addon.gui.controls.indicators.gauges.gauge;

import api.dm.kit.sprites.sprite : Sprite;
import api.dm.gui.controls.control : Control;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.gui.controls.texts.text : Text;
import api.dm.addon.gui.controls.indicators.seven_segment : SevenSegment;
import api.dm.gui.controls.progress.base_radial_progress_bar: BaseRadialProgressBar;
import api.dm.gui.containers.hbox : HBox;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class Gauge : Control
{
    protected
    {
        Text[] labels;

        Sprite outerFace;
        Sprite innerFace;

        double radius = 0;

        double fromAngle = 270;
        double toAngle = 45;

        SevenSegment[] ledSegments;
        HBox ledDisplay;

        BaseRadialProgressBar progressBar;
    }

    this(double radius = 60)
    {
        this.radius = radius;

        const diameter = radius * 2;

        this.width = diameter;
        this.height = diameter;

        import api.dm.kit.sprites.layouts.center_layout : CenterLayout;

        this.layout = new CenterLayout();
        layout.isAutoResize = true;

        isBorder = false;

        invalidateListeners ~= () { layoutSegments; };
    }

    void layoutSegments()
    {
        import api.math.vector2 : Vector2;

        double px = x + width / 2;
        double py = y + height / 2;

        double labelRadius = radius - 25;
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
    
        auto faceStyle = createDefaultStyle;
        if (!faceStyle.isNested)
        {
            faceStyle.lineWidth = 3;
            faceStyle.isFill = false;
        }

        import api.dm.kit.sprites.textures.vectors.shapes.varc: VArc;

        auto newOuterFace = new VArc(radius, faceStyle);
        newOuterFace.fromAngleRad = (3 * Math.PI) / 4;
        newOuterFace.toAngleRad = (Math.PI) / 4;
        outerFace = newOuterFace;
        addCreate(outerFace);

        auto segmentWidth = 5;
        auto segmentHeight = 10;
        auto segmentCount = 20;
        progressBar = new BaseRadialProgressBar(0, 1.0, radius * 2);
        progressBar.innerPadding = 7;
        progressBar.segmentWidth = segmentWidth;
        progressBar.segmentHeight = segmentHeight;
        progressBar.segmentCount = segmentCount;
        progressBar.startAngleDeg = 145;
        progressBar.endAngleDeg = 45;

        addCreate(progressBar);

        auto newInnerFace = new VArc(radius - segmentHeight, faceStyle);
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

        foreach (s; ledSegments)
        {
            s.show0to9(9);
        }

        progressBar.progress = 0.5;
    }

    void reset()
    {
        
    }

    void selectAll()
    {
       
    }

    void selectSegments(size_t count)
    {
        
    }

}
