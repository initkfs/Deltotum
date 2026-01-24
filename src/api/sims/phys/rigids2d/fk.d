module api.sims.phys.rigids2d.fk;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.math.geom2.vec2 : Vec2f;
import Math = api.math;

/**
 * Authors: initkfs
 */

class SegmentWalk : Sprite2d
{
    SegmentChain segments1;
    SegmentChain segments2;

    float cycle = 0;

    //-PI, PI
    float offset = -Math.PI / 2;

    //0, 0.3-0.5
    float speed = 0.1;

    //0, 180
    float thighRange = 45;

    //0, 180
    float thighBase = 90;

    //0, 90
    float calfRange = 45;

    override void create()
    {
        super.create;

        segments1 = new SegmentChain;
        addCreate(segments1);

        segments1.createSegment(100);
        segments1.createSegment(100);

        segments2 = new SegmentChain;
        addCreate(segments2);
        segments2.createSegment(100);
        segments2.createSegment(100);
    }

    override void update(float dt)
    {
        cycle += speed;

        sync(segments1.segments[0], segments1.segments[1], cycle);
		sync(segments2.segments[0], segments2.segments[1], cycle + Math.PI);

        super.update(dt);
    }

    void sync(Segment segA, Segment segB, float cycle = 0)
    {
        const angle1Deg = Math.sin(cycle) * thighRange + thighBase;
        const angle2Deg = Math.sin(cycle + offset) * calfRange + calfRange;
        segA.angle = angle1Deg;
        segB.angle = angle1Deg + angle2Deg;
    }

}

class Segment : Sprite2d
{
    float length;

    this(float length = 100)
    {
        this.length = length;
    }

    override void create()
    {
        super.create;
    }

    override void drawContent()
    {

        super.drawContent;

        import api.dm.kit.graphics.colors.rgba : RGBA;

        graphic.changeColor(RGBA.yellow);
        scope (exit)
        {
            graphic.restoreColor;
        }

        const start = pinStart;
        const end = pinEnd;
        graphic.line(start, end);
        graphic.circle(start.x, start.y, 5);
        graphic.circle(end.x, end.y, 5);
    }

    Vec2f pinStart() => pos;

    void pinStart(Vec2f newPos)
    {
        pos = newPos;
    }

    Vec2f pinEnd()
    {
        const xPos = x + Math.cosDeg(angle) * length;
        const yPos = y + Math.sinDeg(angle) * length;
        return Vec2f(xPos, yPos);
    }

}

class SegmentChain : Sprite2d
{
    Segment[] segments;

    bool isSetPos = true;

    void createSegment(float len = 100)
    {
        auto segment = new Segment(len);
        addCreate(segment);

        if (segments.length > 0)
        {
            auto last = segments[$ - 1];
            segment.pinStart = last.pinEnd;
        }

        segments ~= segment;
    }

    bool segmentAngle(size_t index, float angle)
    {
        if (index >= segments.length)
        {
            return false;
        }

        Segment prev;
        ptrdiff_t lastIndex = index - 1;
        if (lastIndex > 0 && lastIndex < segments.length)
        {
            prev = segments[lastIndex];
        }

        segments[index].angle = !prev ? angle : prev.angle + angle;
        return true;
    }

    override void update(float dt)
    {
        super.update(dt);

        if (segments.length <= 1)
        {
            return;
        }

        if(!isSetPos){
            return;
        }

        Segment last = segments[0];
        foreach (Segment s; segments[1 .. $])
        {
            s.pinStart = last.pinEnd;
            last = s;
        }
    }
}
