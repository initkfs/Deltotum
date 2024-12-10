module api.dm.gui.controls.labels.badge;

import api.dm.gui.controls.labeled : Labeled;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.tooltips.popup : Popup;

import std.conv : to;

/**
 * Authors: initkfs
 */
class Badge : Labeled
{

    this(dstring text = "Badge", string iconName = null, double graphicsGap = 0, bool isCreateLayout = true)
    {
        super(0, 0, text, iconName, graphicsGap, isCreateLayout);
        _labelText = text;

        import api.dm.kit.sprites2d.layouts.managed_layout : ManagedLayout;

        layout.isAutoResize = true;
        isCreateHoverEffect = false;
        isCreateHoverEffectAnimation = false;
        isCreateActionEffect = false;
        isCreateActionEffectAnimation = false;

        isLayoutManaged = false;

        //isCreateBackground = true;
        isBorder = false;
        //isBackground = true;
    }

    override void applyLayout()
    {
        super.applyLayout;

        assert(parent);
        enum margin = 5;
        auto newX = parent.boundsRect.right + margin;
        auto newY = parent.boundsRect.y - boundsRect.halfWidth + margin;
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
