module api.dm.gui.controls.tooltips.popup;

import api.dm.gui.controls.labeled : Labeled;

/**
 * Authors: initkfs
 */
class Popup : Labeled
{
    protected
    {

    }

    this(dstring text = "Popup", string iconName = null, double graphicsGap = 0, bool isCreateLayout = true)
    {
        super(iconName, graphicsGap, isCreateLayout);
        _labelText = text;

        isDrawByParent = false;

        isBorder = false;
        isCreateHoverFactory = false;
        isCreatePointerEffectFactory = false;
        isCreatePointerEffectAnimationFactory = false;

        isVisible = false;
        isLayoutManaged = false;
        isBorder = true;
        isBackground = true;
    }

    override void initialize()
    {
        super.initialize;
    }

    override void create()
    {
        super.create;
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
        const thisBounds = bounds;

        auto newX = parent.bounds.middleX - bounds.halfWidth;
        if (newX < 0)
        {
            newX = 0;
        }
        if (newX + thisBounds.width > screenBounds.right)
        {
            newX = screenBounds.right - thisBounds.width;
        }

        auto newY = parent.bounds.y - bounds.height;
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
