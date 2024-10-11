module api.dm.gui.controls.popups.pointer_popup;

import api.dm.gui.controls.popups.base_popup: BasePopup;

/**
 * Authors: initkfs
 */
class PointerPopup : BasePopup
{
    this(dstring text = "Popup", string iconName = null, double graphicsGap = 0, bool isCreateLayout = true)
    {
        super(text, iconName, graphicsGap, isCreateLayout);
    }

    override void show()
    {
        super.show;
        const screenBounds = screen.first.bounds;
        const thisBounds = bounds;

        auto pointerPos = input.pointerPos;

        enum xOffset = 10;
        enum yOffset = 10;

        auto newX = pointerPos.x + xOffset;
        if (newX < 0)
        {
            newX = 0;
        }

        if (newX + thisBounds.width > screenBounds.right)
        {
            newX = screenBounds.right - thisBounds.width;
        }

        auto newY = pointerPos.y + yOffset;
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
