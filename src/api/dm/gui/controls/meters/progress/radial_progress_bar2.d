module api.dm.gui.controls.meters.progress.radial_progress_bar2;

import api.dm.gui.controls.meters.progress.base_radial_progress_bar : BaseRadialProgressBar;
import api.dm.gui.controls.texts.text : Text;

import std.conv : to, text;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class RadialProgressBar2 : BaseRadialProgressBar
{
    protected
    {
        Text label;
    }

    bool isPercentMode;
    dstring percentChar = "%";

    //TODO formatters
    dstring prefixText;
    dstring postfixText;

   // Sprite2d[] secIndicatorSegments;

    this(double minValue = 0, double maxValue = 1.0, double diameter = 100)
    {
        super(minValue, maxValue, diameter);

        import api.dm.kit.sprites.sprites2d.layouts.center_layout : CenterLayout;

        this.layout = new CenterLayout;
    }

    override void initialize()
    {
        super.initialize;
    }

    override void create()
    {
        super.create;

        label = new Text;
        addCreate(label);
        setText;

        // foreach (i; 0 .. 60)
        // {
        //     auto segment = new VArc(radius, GraphicStyle(5, theme.colorAccent), width, width);
        //     segment.xCenter = 0;
        //     segment.yCenter = 0;

        //     auto angleOffset = 360 / 60 / 2;
        //     auto stAngle = 360.0 / 60 * i + angleOffset - 90;
        //     auto endAngle = stAngle + 360 / 60;
        //     segment.fromAngleRad = Math.degToRad(stAngle);
        //     segment.toAngleRad = Math.degToRad(endAngle);
        //     addCreate(segment);
        //     segment.isVisible = false;
        //     secIndicatorSegments ~= segment;
        //     //segment.angle = 360.0 * i / 60.0;
        // }
    }

    protected void setText()
    {
        if (!label)
        {
            return;
        }
        dstring postfix = isPercentMode ? percentChar ~ postfixText : postfixText;
        //TODO remove concat
        //TODO value calculator\formatter
        auto progressValue = progress;
        if(isPercentMode){
            progressValue = Math.round((progressValue * 100) /  maxValue);
        } 
        dstring text = prefixText ~ progressValue.to!dstring ~ postfix;
        label.text = text;
    }

    override void reset()
    {
        super.reset;
        if (label)
        {
            label.text = "";
        }
    }

    override double progress()
    {
        return super.progress;
    }

    override bool progress(double v)
    {
        const isChange = super.progress(v);
        if (isChange && label)
        {
            setText;
        }
        return isChange;
    }
}
