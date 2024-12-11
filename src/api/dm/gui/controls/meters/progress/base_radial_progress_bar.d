module api.dm.gui.controls.meters.progress.base_radial_progress_bar;

import api.dm.gui.controls.meters.radial_min_value_meter: RadialMinValueMeter;
import api.dm.com.graphics.com_texture : ComTextureScaleMode;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.math.geom2.rect2 : Rect2d;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class BaseRadialProgressBar : RadialMinValueMeter!double
{
    
    this(double diameter = 0, double minValue = 0, double maxValue = 1.0, double minAngleDeg = 0, double maxAngleDeg = 360)
    {
        super(diameter, minValue, maxValue, minAngleDeg, maxAngleDeg);
    }


    // override void create()
    // {
    //     super.create;



    //     foreach (i; 0 .. segmentCount)
    //     {
    //         auto newSegmentShape = createSegmentShape(segmentStyle);
    //         scope (exit)
    //         {
    //             newSegmentShape.dispose;
    //         }

    //         auto segment = createSegment(newSegmentShape);
    //         add(segment);
    //         segments ~= segment;

    //         auto newSegmentFillShape = createFillSegmentShape(fillStyle);
    //         scope (exit)
    //         {
    //             newSegmentFillShape.dispose;
    //         }

    //         auto fillSegment = createSegment(newSegmentFillShape);
    //         fillSegment.isVisible = false;
    //         add(fillSegment);
    //         fillSegments ~= fillSegment;
    //     }

    //     layoutChildren;

    //     if (progress != minValue)
    //     {
    //         fillProgress(progress);
    //     }
    // }

    // override bool progress(double newValue)
    // {
    //     const isChange = super.progress(newValue);
    //     if (!isChange)
    //     {
    //         return isChange;
    //     }

    //     fillProgress(value);

    //     return isChange;
    // }

    // protected void fillProgress(double progressValue)
    // {
    //     reset;

    //     import std.math.operations : isClose;

    //     if (isClose(progressValue, maxValue))
    //     {
    //         fill;
    //     }
    //     else if (isClose(progressValue, minValue))
    //     {
    //         reset;
    //     }
    //     else
    //     {
    //         import std.conv : to;

    //         auto range = maxValue - minValue;

    //         auto count = Math.round((progressValue * fillSegments.length) / range).to!size_t;
    //         if (count > fillSegments.length)
    //         {
    //             count = fillSegments.length;
    //         }

    //         fill(count);
    //     }
    // }

    // protected void fill()
    // {
    //     fill(fillSegments.length);
    // }

    // protected void fill(size_t count)
    // {
    //     if (count > fillSegments.length)
    //     {
    //         import std.format : format;

    //         throw new Exception(format("Filled segments %s exceeds their count %s", count, fillSegments
    //                 .length));
    //     }

    //     foreach (s; fillSegments[0 .. count])
    //     {
    //         s.isVisible = true;
    //     }
    // }
}
