module api.dm.gui.controls.containers.base.spaceable_container;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.layouts.spaceable_layout : SpaceableLayout;
import api.dm.kit.sprites2d.layouts.layout2d : Layout2d;
import api.dm.gui.controls.containers.container : Container;

/**
 * Authors: initkfs
 */
class SpaceableContainer : Container
{
    private
    {
        float _spacing = 0;
    }

    this(float spacing = SpaceableLayout.DefaultSpacing, Control[] children)
    {
        this(spacing, null, true, null, children);
    }

    this(float spacing = SpaceableLayout.DefaultSpacing, scope Layout2d delegate() defaultLayoutProvider, bool isLayout = true, scope Layout2d delegate() layoutProvider = null, Control[] children)
    {
        super(defaultLayoutProvider, isLayout, layoutProvider, children);
        this._spacing = spacing;
    }

    float spacing() => _spacing;

    void spacing(float value)
    {
        _spacing = value;

        if (auto spaceLayout = cast(SpaceableLayout) layout)
        {
            spaceLayout.spacing = _spacing;
        }
    }

    override void enablePadding()
    {
        //TODO lazy flag
        super.enablePadding;
        enableSpacing;
    }

    bool enableSpacing()
    {
        debug
        {
            if (!hasGraphic || !theme)
            {
                throw new Exception(
                    "Unable to enable spacing: graphic or theme is null. Perhaps the component is not built correctly");
            }
        }

        if (theme)
        {
            const value = theme.controlSpacing;
            spacing = value;
            return true;
        }

        return false;
    }

}
