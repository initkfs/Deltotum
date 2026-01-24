module api.sims.phys.rigids2d.ik;

import api.sims.phys.rigids2d.fk;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.math.geom2.vec2 : Vec2f;
import Math = api.math;

/**
 * Authors: initkfs
 */

class SegmentDrag : Sprite2d
{
    SegmentChain chain;

    override void create()
    {
        super.create;

        chain = new SegmentChain;
        addCreate(chain);
        chain.isSetPos = false;

        chain.createSegment;
        chain.createSegment;
        chain.createSegment;
    }

    override void update(float dt)
    {
        super.update(dt);

        if (chain.segments.length == 0)
        {
            return;
        }

        const pos = input.pointerPos;

        //Reach
        auto target = reach(chain.segments[0], pos.x, pos.y);

        foreach (i; 1..chain.segments.length)
        {
            auto segment = chain.segments[i];
            target = reach(segment, target.x, target.y);
        }

        ptrdiff_t i = chain.segments.length - 1;
        while (i > 0)
        {
            auto segmentA = chain.segments[i];
            auto segmentB = chain.segments[i - 1];
            segmentB.pos = segmentA.pinEnd();

            i--;
        }

        //Dragging
        // drag(chain.segments[0], pos.x, pos.y);

        // if (chain.segments.length <= 1)
        // {
        //     return;
        // }

        // foreach (i; 1 .. chain.segments.length)
        // {
        //     auto curr = chain.segments[i];
        //     auto prev = chain.segments[i - 1];
        //     drag(curr, prev.x, prev.y);
        // }
    }

    Vec2f reach(Segment segment, float xPos, float yPos)
    {
        const dx = xPos - segment.x;
        const dy = yPos - segment.y;
        const angle = Math.atan2(dy, dx);
        segment.angle = angle * 180 / Math.PI;

        const w = segment.pinEnd.x - segment.x;
        const h = segment.pinEnd.y - segment.y;
        // segment.x = xPos - w;
        // segment.y = yPos - h;
        return Vec2f(xPos - w, yPos - h);
    }

    void drag(Segment segment, float xPos, float yPos)
    {
        const pos = reach(segment, xPos, yPos);
        segment.x = pos.x;
        segment.y = pos.y;
    }
}
