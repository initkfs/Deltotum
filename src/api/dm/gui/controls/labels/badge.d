module api.dm.gui.controls.labels.badge;

import api.dm.gui.controls.labeled : Labeled;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.gui.controls.tooltips.popup : Popup;

import std.conv : to;

/**
 * Authors: initkfs
 */
class Badge : Labeled
{

    this(dstring text = "Badge", string iconName = null, double graphicsGap = 0, bool isCreateLayout = true)
    {
        super(0, 0, iconName, graphicsGap, text, isCreateLayout);
        _labelText = text;

        import api.dm.kit.sprites.layouts.managed_layout : ManagedLayout;

        layout.isAutoResize = true;
        isCreateHover = false;
        isCreateHoverAnimation = false;
        isCreateActionEffect = false;
        isCreateActionAnimation = false;

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
