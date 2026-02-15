module api.dm.gui.controls.labels.label;

import api.dm.gui.controls.labeled : Labeled;

/**
 * Authors: initkfs
 */
class Label : Labeled
{
    this(dstring text = "Label", dchar iconName = dchar.init, float graphicsGap = 0)
    {
        super(text, iconName, graphicsGap, isCreateLayout : true);

        isCreateLabelText = true;
        isCreateLabelIcon = true;
    }

}
