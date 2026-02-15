module api.dm.gui.controls.popups.base_text_popup;

import api.dm.gui.controls.popups.base_popup : BasePopup;
import api.dm.gui.controls.labeled : Labeled;

/**
 * Authors: initkfs
 */
class BaseTextPopup : BasePopup
{
    Labeled label;

    bool isCreateLabel = true;
    Labeled delegate(Labeled) onNewLabel;
    void delegate(Labeled) onConfiguredLabel;
    void delegate(Labeled) onCreatedLabel;

    protected
    {
        dstring _labelText;
        dchar _iconName;
        float _graphicsGap = 0;
    }

    this(dstring text = "Popup", dchar iconName = dchar.init, float graphicsGap = 0, bool isCreateLayout = true)
    {
        super(isCreateLayout);

        _labelText = text;
        _iconName = iconName;
        _graphicsGap = graphicsGap;

        isBackground = true;
    }

    override void create()
    {
        super.create;

        if (!label && isCreateLabel)
        {
            auto l = newLabel(width, height, _labelText, _iconName, _graphicsGap);
            label = !onNewLabel ? l : onNewLabel(l);

            if (onConfiguredLabel)
            {
                onConfiguredLabel(label);
            }

            addCreate(label);

            if (onCreatedLabel)
            {
                onCreatedLabel(label);
            }
        }

        enablePadding;
    }

    Labeled newLabel(float width = 0, float height = 0, dstring labelText = null, dchar iconName = dchar.init, float graphicsGap = 0)
    {
        auto label = new Labeled(labelText, iconName, graphicsGap);
        label.resize(width, height);
        return label;
    }

    void text(dstring t)
    {
        assert(label);
        label.text = t;
    }

    void text(string t)
    {
        assert(label);
        label.text = t;
    }

}
