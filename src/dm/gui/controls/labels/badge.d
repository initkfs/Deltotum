module dm.gui.controls.labels.badge;

import dm.gui.controls.labeled : Labeled;
import dm.kit.sprites.sprite : Sprite;
import dm.gui.controls.tooltips.tooltip : Tooltip;

import std.conv : to;

/**
 * Authors: initkfs
 */
class Badge : Labeled
{

    this(dstring text = "Badge", string iconName = null, double graphicsGap = 0, bool isCreateLayout = true)
    {
        super(iconName, graphicsGap, isCreateLayout);
        _labelText = text;

        import dm.kit.sprites.layouts.managed_layout : ManagedLayout;

        layout.isAutoResize = true;
        isCreateHoverFactory = false;
        isCreatePointerEffectFactory = false;
        isCreatePointerEffectAnimationFactory = false;

        isLayoutManaged = false;

        //isCreateBackgroundFactory = true;
        isBorder = false;
        //isBackground = true;
    }

    override void applyLayout()
    {
        super.applyLayout;

        assert(parent);
        enum margin = 5;
        auto newX = parent.bounds.right + margin;
        auto newY = parent.bounds.y - bounds.halfWidth + margin;
        x = newX;
        y = newY;
    }

    override void initialize()
    {
        super.initialize;
    }

    override void create()
    {
        super.create;
    }

}
