module api.dm.gui.controls.progress.base_radial_progress_bar;

import api.dm.gui.controls.progress.base_progress_bar : BaseProgressBar;
import api.dm.com.graphics.com_texture : ComTextureScaleMode;
import api.dm.kit.sprites.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;
import api.math.geom2.rect2 : Rect2d;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class BaseRadialProgressBar : BaseProgressBar
{
    double innerPadding = 10;
    protected
    {
        double diameter = 0;

        Sprite2d[] segments;
        Sprite2d[] fillSegments;
    }

    double segmentCount = 10;
    double segmentWidth = 5;
    double segmentHeight = 20;
    double startAngleDeg = 180;
    double endAngleDeg = 180;

    this(double minValue = 0, double maxValue = 1.0, double diameter = 100)
    {
        super(minValue, maxValue);

        if (diameter <= 0)
        {
            import std.conv : text;

            throw new Exception(text("Diameter must be a positive value, but recieved: ", diameter));
        }

        this.diameter = diameter;

        this.width = diameter;
        this.height = diameter;
    }

    override void initialize()
    {
        super.initialize;
    }

    override void create()
    {
        super.create;

        import std.conv : to;

        auto segmentStyle = createStyle;
        if (!segmentStyle.isNested)
        {
            segmentStyle.isFill = false;
            segmentStyle.color = theme.colorAccent;
        }

        auto fillStyle = segmentStyle;
        if (!fillStyle.isNested)
        {
            fillStyle.isFill = true;
        }

        foreach (i; 0 .. segmentCount)
        {
            auto newSegmentShape = createSegmentShape(segmentStyle);
            scope (exit)
            {
                newSegmentShape.dispose;
            }

            auto segment = createSegment(newSegmentShape);
            add(segment);
            segments ~= segment;

            auto newSegmentFillShape = createFillSegmentShape(fillStyle);
            scope (exit)
            {
                newSegmentFillShape.dispose;
            }

            auto fillSegment = createSegment(newSegmentFillShape);
            fillSegment.isVisible = false;
            add(fillSegment);
            fillSegments ~= fillSegment;
        }

        layoutChildren;

        if (progress != minValue)
        {
            fillProgress(progress);
        }
    }

    void layoutChildren()
    {
        assert(segments.length == fillSegments.length);

        import api.math.geom2.vec2 : Vec2d;

        double radius = diameter / 2 - innerPadding;

        const cx = boundsRect.middleX;
        const cy = boundsRect.middleY;

        double angleRange = Math.abs(endAngleDeg - startAngleDeg);
        double angleDt = (360.0 - angleRange) / segments.length;
        double angle = startAngleDeg;
        foreach (i, s; segments)
        {
            const coords = Vec2d.fromPolarDeg(angle, radius);

            s.x = cx + coords.x - s.width / 2;
            s.y = cy + coords.y - s.height / 2;
            s.angle = angle;

            angle += angleDt;
            // if(angle > 360){
            //     angle = 0;
            // }

            auto fillSegment = fillSegments[i];
            fillSegment.x = s.x;
            fillSegment.y = s.y;
            fillSegment.angle = s.angle;
        }
    }

    Sprite2d createSegment(Texture2d segmentShape)
    {
        import api.dm.kit.sprites.sprites2d.textures.texture2d : Texture2d;

        //TODO instability at small sizes, possible artifacts
        auto rotateDiameter = Math.round(Math.sqrt((segmentWidth ^^ 2) + (segmentHeight ^^ 2)));
        auto segmentSize = rotateDiameter * 3;

        auto segment = new Texture2d(segmentSize, segmentSize);
        segment.isResizable = false;

        auto srcRect = Rect2d(0, 0, segmentWidth, segmentHeight);
        auto destRect = Rect2d(segment.width / 2 - segmentWidth / 2, segment.height / 2 - segmentHeight / 2, segmentWidth, segmentHeight);

        build(segment);
        segment.initialize;
        assert(segment.isInitialized);
        segment.create;
        assert(segment.isCreated);

        segment.copyFrom(segmentShape, srcRect, destRect);

        segment.isLayoutManaged = false;
        segment.textureScaleMode = ComTextureScaleMode.balance;

        return segment;
    }

    Texture2d createSegmentShape(GraphicStyle style)
    {
        import api.dm.kit.sprites.sprites2d.textures.vectors.shapes.vconvex_polygon : VConvexPolygon;

        auto sprite = new VConvexPolygon(segmentWidth, segmentHeight, style, 0);
        build(sprite);
        sprite.initialize;
        assert(sprite.isInitialized);
        sprite.create;
        assert(sprite.isCreated);
        return sprite;
    }

    Texture2d createFillSegmentShape(GraphicStyle style)
    {
        return createSegmentShape(style);
    }

    void reset()
    {
        foreach (s; fillSegments)
        {
            s.isVisible = false;
        }
    }

    alias progress = BaseProgressBar.progress;

    override bool progress(double newValue)
    {
        const isChange = super.progress(newValue);
        if (!isChange)
        {
            return isChange;
        }

        fillProgress(value);

        return isChange;
    }

    protected void fillProgress(double progressValue)
    {
        reset;

        import std.math.operations : isClose;

        if (isClose(progressValue, maxValue))
        {
            fill;
        }
        else if (isClose(progressValue, minValue))
        {
            reset;
        }
        else
        {
            import std.conv : to;

            auto range = maxValue - minValue;

            auto count = Math.round((progressValue * fillSegments.length) / range).to!size_t;
            if (count > fillSegments.length)
            {
                count = fillSegments.length;
            }

            fill(count);
        }
    }

    protected void fill()
    {
        fill(fillSegments.length);
    }

    protected void fill(size_t count)
    {
        if (count > fillSegments.length)
        {
            import std.format : format;

            throw new Exception(format("Filled segments %s exceeds their count %s", count, fillSegments
                    .length));
        }

        foreach (s; fillSegments[0 .. count])
        {
            s.isVisible = true;
        }
    }
}
