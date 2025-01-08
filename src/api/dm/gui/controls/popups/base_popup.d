module api.dm.gui.controls.popups.base_popup;

import api.dm.gui.controls.control : Control;

/**
 * Authors: initkfs
 */
class BasePopup : Control
{
    this()
    {

    }

    override void create()
    {

    }

    override void show()
    {

        super.show;

        auto pointerPos = input.pointerPos;
        show(pointerPos.x, pointerPos.y);
    }

    void show(double x, double y)
    {
        const screenBounds = screen.first.bounds;
        const thisBounds = boundsRect;

        auto newX = x;
        if (newX < 0)
        {
            newX = 0;
        }

        if (newX + thisBounds.width > screenBounds.right)
        {
            newX = screenBounds.right - thisBounds.width;
        }

        auto newY = y;
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

        if (!isVisible)
        {
            isVisible = true;
        }
    }
}
