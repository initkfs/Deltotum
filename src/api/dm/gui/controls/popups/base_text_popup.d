module api.dm.gui.controls.popups.base_text_popup;

import api.dm.gui.controls.popups.base_popup : BasePopup;
import api.dm.gui.controls.labeled : Labeled;

/**
 * Authors: initkfs
 */
class BaseTextPopup : BasePopup
{
    protected
    {
        dstring _labelText;
        string _iconName;
        double _graphicsGap = 0;

        Labeled label;

        bool isCreateLabel = true;
        Labeled delegate(Labeled) onNewLabel;
        void delegate(Labeled) onCreatedLabel;
    }

    this(dstring text = "Popup", string iconName = null, double graphicsGap = 0, bool isCreateLayout = true)
    {
        _labelText = text;
        _iconName = iconName;
        _graphicsGap = graphicsGap;

        isDrawByParent = false;

        isVisible = false;
        isLayoutManaged = false;
        isBackground = true;

        import api.dm.kit.sprites2d.layouts.center_layout : CenterLayout;

        if (isCreateLayout)
        {
            layout = new CenterLayout;
            layout.isAutoResize = true;
        }
    }

    override void create()
    {
        super.create;

        if (!label && isCreateLabel)
        {
            auto l = newLabel(width, height, _labelText, _iconName, _graphicsGap);
            label = !onNewLabel ? l : onNewLabel(l);
            
            addCreate(label);

            if (onCreatedLabel)
            {
                onCreatedLabel(label);
            }
        }

        enableInsets;
    }

    Labeled newLabel(double width = 0, double height = 0, dstring labelText = null, string iconName = null, double graphicsGap = 0)
    {
        return new Labeled(width, height, labelText, iconName, graphicsGap);
    }

}
