module api.dm.gui.controls.meters.progress.base_radial_progress_bar;

import api.dm.gui.controls.meters.radial_min_max_value_meter : RadialMinMaxValueMeter;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.indicators.segments.radial_segment_bar : RadialSegmentBar;

import std.conv : to, text;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class BaseRadialProgressBar : RadialMinMaxValueMeter!double
{
    //TODO extract to super
    protected
    {
        double _value = 0;
    }

    double progressStep = 0.1;

    void delegate(double oldV, double newV)[] onOldNewValue;

    RadialSegmentBar segmentBar;

    bool isCreateSegmentBar = true;
    RadialSegmentBar delegate(RadialSegmentBar) onSegmentBarCreate;
    void delegate(RadialSegmentBar) onSegmentBarCreated;

    Text label;

    bool isCreateLabel = true;
    Text delegate(Text) onLabelCreate;
    void delegate(Text) onLabelCreated;

    bool isPercentMode;

    this(double diameter = 0, double minValue = 0, double maxValue = 1.0, double minAngleDeg = 0, double maxAngleDeg = 360)
    {
        super(diameter, minValue, maxValue, minAngleDeg, maxAngleDeg);

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
        super.create;

        if (!segmentBar && isCreateSegmentBar)
        {
            auto newBar = newSegmentBar;
            segmentBar = !onSegmentBarCreate ? newBar : onSegmentBarCreate(newBar);
            addCreate(segmentBar);
            if (onSegmentBarCreated)
            {
                onSegmentBarCreated(segmentBar);
            }
        }

        if (!label && isCreateLabel)
        {
            auto nl = newLabel;
            label = !onLabelCreate ? nl : onLabelCreate(nl);
            addCreate(label);
            if (onLabelCreated)
            {
                onLabelCreated(label);
            }
        }

        setProgressData(0, 0);
    }

    RadialSegmentBar newSegmentBar()
    {
        auto bar = new RadialSegmentBar(diameter, minAngleDeg, maxAngleDeg);

        assert(progressStep > 0);

        import std.conv : to;

        bar.segmentsCount = (maxValue / progressStep).to!size_t;
        bar.angleOffset += bar.segmentAngleMiddleOffset;

        return bar;
    }

    Text newLabel()
    {
        return new Text;
    }

    void triggerListeners(double oldV, double newV)
    {
        if (onOldNewValue.length > 0)
        {
            foreach (dg; onOldNewValue)
            {
                assert(dg);
                dg(oldV, newV);
            }
        }
    }

    protected void setProgressData(double oldV, double newV)
    {
        setLabelText(oldV, newV);
        setSegmentsFill(oldV, newV);
    }

    double value() => _value;

    bool value(double newValue, bool isTriggerListeners = true)
    {
        if (_value == newValue)
        {
            return false;
        }
        double oldValue = _value;
        _value = Math.clamp(newValue, minValue, maxValue);
        if (isTriggerListeners)
        {
            triggerListeners(oldValue, _value);
        }

        setProgressData(oldValue, _value);

        return true;
    }

    protected void setSegmentsFill(double oldV, double newV)
    {
        assert(segmentBar);

        segmentBar.hideSegments;

        if(newV == minValue){
            return;
        }

        const segments = segmentBar.segmentsCount;
        auto needSegments = cast(size_t) Math.clamp(Math.round(newV * segments / maxValue), 0, segments);
        segmentBar.showSegments(needSegments);
    }

    protected void setLabelText(double oldV, double newV)
    {
        import std.format : format;

        if (isPercentMode)
        {
            label.text = format("%.2f", newV);
            return;
        }

        auto percent = newV * 100 / maxValue;
        label.text = format("%.1f%%", percent);
    }
}
