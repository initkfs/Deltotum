module api.dm.gui.controls.meters.progress.radial_progress_bar;

import api.dm.gui.controls.meters.progress.base_radial_progress_bar : BaseRadialProgressBar;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.styles.graphic_style: GraphicStyle;
import api.dm.gui.controls.texts.text : Text;

import std.conv : to, text;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class RadialProgressBar : BaseRadialProgressBar
{
    Sprite2d[] segments;
    size_t segmentsCount = 5;

    GraphicStyle segmentStyle;

    protected
    {
        Text label;
    }

    this(double diameter = 0, double minValue = 0, double maxValue = 1.0, double minAngleDeg = 0, double maxAngleDeg = 180)
    {
        super(diameter, minValue, maxValue, minAngleDeg, maxAngleDeg);

        import api.dm.kit.sprites.sprites2d.layouts.center_layout : CenterLayout;

        this.layout = new CenterLayout;
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
        _width = diameter;
        _height = diameter;
    }

    override void create()
    {
        super.create;

        if (capGraphics.isVectorGraphics)
        {
            import api.dm.kit.sprites.sprites2d.textures.vectors.shapes.varc : VArc;

            auto style = segmentStyle == GraphicStyle.init ? createFillStyle : segmentStyle;

            double angleDiff = 360 / segmentsCount;
            double angleOffset = angleDiff / 2;

            foreach (i; 0 .. segmentsCount)
            {
                auto segment = new VArc(radius, style);

                segment.xCenter = 0;
                segment.yCenter = 0;
                auto stAngle = angleDiff * i - angleOffset - 90;
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

    // protected void setText()
    // {
    //     if (!label)
    //     {
    //         return;
    //     }
    //     dstring postfix = isPercentMode ? percentChar ~ postfixText : postfixText;
    //     //TODO remove concat
    //     //TODO value calculator\formatter
    //     auto progressValue = progress;
    //     if (isPercentMode)
    //     {
    //         progressValue = Math.round((progressValue * 100) / maxValue);
    //     }
    //     dstring text = prefixText ~ progressValue.to!dstring ~ postfix;
    //     label.text = text;
    // }

    // override void reset()
    // {
    //     super.reset;
    //     if (label)
    //     {
    //         label.text = "";
    //     }
    // }

    // override double progress()
    // {
    //     return super.progress;
    // }

    // override bool progress(double v)
    // {
    //     const isChange = super.progress(v);
    //     if (isChange && label)
    //     {
    //         setText;
    //     }
    //     return isChange;
    // }
}

// module api.dm.gui.controls.meters.progress.radial_progress_bar;

// import api.dm.gui.controls.meters.progress.base_radial_progress_bar : BaseRadialProgressBar;
// import api.dm.gui.controls.texts.text : Text;

// import std.conv : to, text;

// import Math = api.dm.math;

// /**
//  * Authors: initkfs
//  */
// class RadialProgressBar : BaseRadialProgressBar
// {
//     protected
//     {
//         Text label;
//     }

//     bool isPercentMode;
//     dstring percentChar = "%";

//     //TODO formatters
//     dstring prefixText;
//     dstring postfixText;

//     this(double minValue = 0, double maxValue = 1.0, double diameter = 100)
//     {
//         super(diameter, minValue, maxValue, 0, 0);

//         import api.dm.kit.sprites.sprites2d.layouts.center_layout : CenterLayout;

//         this.layout = new CenterLayout;
//     }

//     // override void initialize()
//     // {
//     //     super.initialize;
//     // }

//     // override void create()
//     // {
//     //     super.create;

//     //     label = new Text;
//     //     addCreate(label);
//     //     setText;
//     // }

//     protected void setText()
//     {
//         if (!label)
//         {
//             return;
//         }
//         dstring postfix = isPercentMode ? percentChar ~ postfixText : postfixText;
//         //TODO remove concat
//         //TODO value calculator\formatter
//         auto progressValue = progress;
//         if(isPercentMode){
//             progressValue = Math.round((progressValue * 100) /  maxValue);
//         } 
//         dstring text = prefixText ~ progressValue.to!dstring ~ postfix;
//         label.text = text;
//     }

//     override void reset()
//     {
//         super.reset;
//         if (label)
//         {
//             label.text = "";
//         }
//     }

//     override double progress()
//     {
//         return super.progress;
//     }

//     override bool progress(double v)
//     {
//         const isChange = super.progress(v);
//         if (isChange && label)
//         {
//             setText;
//         }
//         return isChange;
//     }
// }
