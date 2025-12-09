module api.dm.gui.controls.meters.progress.radial_progress_bar;

import api.dm.gui.controls.meters.progress.base_radial_progress_bar: BaseRadialProgressBar;


/**
 * Authors: initkfs
 */
class RadialProgressBar : BaseRadialProgressBar
{
    this(float diameter = 0, float minValue = 0, float maxValue = 1.0, float minAngleDeg = 0, float maxAngleDeg = 180)
    {
        super(diameter, minValue, maxValue, minAngleDeg, maxAngleDeg);
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

    // override float progress()
    // {
    //     return super.progress;
    // }

    // override bool progress(float v)
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

//     this(float minValue = 0, float maxValue = 1.0, float diameter = 100)
//     {
//         super(diameter, minValue, maxValue, 0, 0);

//         import api.dm.kit.sprites2d.layouts.center_layout : CenterLayout;

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

//     override float progress()
//     {
//         return super.progress;
//     }

//     override bool progress(float v)
//     {
//         const isChange = super.progress(v);
//         if (isChange && label)
//         {
//             setText;
//         }
//         return isChange;
//     }
// }
