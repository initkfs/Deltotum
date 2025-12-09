module api.dm.gui.controls.popups.base_popup;

import api.dm.gui.controls.control : Control;

/**
 * Authors: initkfs
 */
class BasePopup : Control
{
    void delegate()[] onShow;

    float showPadding = 10;

    this(bool isCreateLayout = true)
    {
        isDrawByParent = false;

        isVisible = false;
        isLayoutManaged = false;
        isResizedByParent = false;

        isBackground = true;

        if (isCreateLayout)
        {
            import api.dm.kit.sprites2d.layouts.center_layout : CenterLayout;

            layout = new CenterLayout;
            layout.isAutoResize = true;
            layout.isDecreaseRootSize = true;
        }
    }

    void showForPointer()
    {
        super.show;

        auto pointerPos = input.pointerPos;
        show(pointerPos.x, pointerPos.y);
    }

    void show(float x, float y)
    {
        const windowBounds = window.boundsLocal;
        const thisBounds = boundsRect;

        auto newX = showPadding + x;
        if (newX < 0)
        {
            newX = 0;
        }

        if (newX + thisBounds.width > windowBounds.right)
        {
            newX = windowBounds.right - thisBounds.width;
        }

        auto newY = y;
        if (newY < 0)
        {
            newY = 0;
        }

        if (newY + thisBounds.height > windowBounds.bottom)
        {
            newY = windowBounds.bottom - thisBounds.height;
        }

        this.x = newX;
        this.y = newY;

        if (!isVisible)
        {
            isVisible = true;
        }

        if (onShow.length > 0)
        {
            foreach (dg; onShow)
            {
                dg();
            }
        }
    }
}
