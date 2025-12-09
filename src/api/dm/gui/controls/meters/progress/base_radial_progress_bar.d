module api.dm.gui.controls.meters.progress.base_radial_progress_bar;

import api.dm.gui.controls.meters.progress.base_labeled_progress_bar : BaseLabeledProgressBar;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.gui.controls.indicators.segmentbars.radial_segmentbar : RadialSegmentBar;

import std.conv : to, text;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class BaseRadialProgressBar : BaseLabeledProgressBar
{
    float minAngleDeg = 0;
    float maxAngleDeg = 0;

    float diameter = 0;

    RadialSegmentBar segmentBar;

    bool isCreateSegmentBar = true;
    RadialSegmentBar delegate(RadialSegmentBar) onNewSegmentBar;
    void delegate(RadialSegmentBar) onConfiguredSegmentBar;
    void delegate(RadialSegmentBar) onCreatedSegmentBar;

    this(float diameter = 0, float minValue = 0, float maxValue = 1.0, float minAngleDeg = 0, float maxAngleDeg = 360)
    {
        super(minValue, maxValue);

        this.diameter = diameter;

        this.minAngleDeg = minAngleDeg;
        this.maxAngleDeg = maxAngleDeg;

        import api.dm.kit.sprites2d.layouts.center_layout : CenterLayout;

        this.layout = new CenterLayout;
        layout.isAutoResize = true;
    }

    override void initialize()
    {
        super.initialize;
    }

    override void loadTheme()
    {
        super.loadTheme;

        if (diameter == 0)
        {
            diameter = theme.meterThumbDiameter;
        }

        assert(diameter > 0);
        initSize(diameter, diameter);
    }

    override void create()
    {
        if (!segmentBar && isCreateSegmentBar)
        {
            auto newBar = newSegmentBar;
            segmentBar = !onNewSegmentBar ? newBar : onNewSegmentBar(newBar);

            assert(progressStep > 0);

            import std.conv : to;

            segmentBar.segmentsCount = (maxValue / progressStep).to!size_t;

            if (onConfiguredSegmentBar)
            {
                onConfiguredSegmentBar(segmentBar);
            }

            addCreate(segmentBar);

            if (onCreatedSegmentBar)
            {
                onCreatedSegmentBar(segmentBar);
            }
        }

        super.create;

        setProgressData(0, 0);
    }

    RadialSegmentBar newSegmentBar()
    {
        auto bar = new RadialSegmentBar(diameter, minAngleDeg, maxAngleDeg);
        //bar.angleOffset += bar.segmentAngleMiddleOffset;
        return bar;
    }

    override protected void setProgressData(float oldV, float newV)
    {
        super.setProgressData(oldV, newV);
        setSegmentsFill(oldV, newV);
    }

    protected void setSegmentsFill(float oldV, float newV)
    {
        assert(segmentBar);

        segmentBar.hideSegments;

        if (newV == minValue)
        {
            return;
        }

        const segments = segmentBar.segmentsCount;
        auto needSegments = cast(size_t) Math.clamp(Math.round(newV * segments / maxValue), 0, segments);
        segmentBar.showSegments(needSegments);
    }

}
