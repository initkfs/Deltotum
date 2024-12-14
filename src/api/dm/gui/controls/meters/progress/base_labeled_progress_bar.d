module api.dm.gui.controls.meters.progress.base_labeled_progress_bar;

import api.dm.gui.controls.meters.progress.base_progress_bar : BaseProgressBar;
import api.dm.gui.controls.texts.text : Text;

/**
 * Authors: initkfs
 */
abstract class BaseLabeledProgressBar : BaseProgressBar
{
    Text label;

    bool isCreateLabel = true;
    Text delegate(Text) onNewLabel;
    void delegate(Text) onCreatedLabel;

    bool isPercentMode = true;

    this(double minValue = 0, double maxValue = 1.0)
    {
        super(minValue, maxValue);
    }

    override void create()
    {
        super.create;

        if (!label && isCreateLabel)
        {
            auto nl = newLabel;
            label = !onNewLabel ? nl : onNewLabel(nl);
            addCreate(label);
            if (onCreatedLabel)
            {
                onCreatedLabel(label);
            }
        }
    }

    Text newLabel()
    {
        return new Text("0");
    }

    override protected void setProgressData(double oldV, double newV)
    {
        if(label){
            setLabelText(oldV, newV);
        }
    }

    protected void setLabelText(double oldV, double newV)
    {
        assert(label);

        import std.format : format;

        if (!isPercentMode)
        {
            label.text = format("%.2f", newV);
            return;
        }

        auto percent = newV * 100 / maxValue;
        label.text = format("%.1f%%", percent);
    }
}
