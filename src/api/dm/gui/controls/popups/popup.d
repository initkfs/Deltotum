module api.dm.gui.controls.tooltips.popup;

import api.dm.gui.controls.popups.base_popup: BasePopup;

/**
 * Authors: initkfs
 */
class Popup : BasePopup
{
    protected
    {

    }

    this(dstring text = "Popup", string iconName = null, double graphicsGap = 0, bool isCreateLayout = true)
    {
        super(text, iconName, graphicsGap, isCreateLayout);
    }

    override void show()
    {
        super.show;
        if (!parent)
        {
            return;
        }

        import Math = api.dm.math;

        const screenBounds = screen.first.bounds;
        const thisBounds = rectBounds;

        auto newX = parent.rectBounds.middleX - rectBounds.halfWidth;
        if (newX < 0)
        {
            newX = 0;
        }
        if (newX + thisBounds.width > screenBounds.right)
        {
            newX = screenBounds.right - thisBounds.width;
        }

        auto newY = parent.rectBounds.y - rectBounds.height;
        if (newY < 0)
        {
            newY = 0;
        }

        if (newY + thisBounds.height > screenBounds.height)
        {
            newY = screenBounds.height - thisBounds.height;
        }

        this.x = newX;
        this.y = newY;
    }
}
