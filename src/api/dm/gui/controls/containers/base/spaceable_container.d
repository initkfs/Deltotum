module api.dm.gui.controls.containers.base.spaceable_container;

import api.dm.kit.sprites2d.layouts.spaceable_layout : SpaceableLayout;

import api.dm.gui.controls.containers.container : Container;

/**
 * Authors: initkfs
 */
class SpaceableContainer : Container
{
    private
    {
        double _spacing = 0;
    }

    this(double spacing = SpaceableLayout.DefaultSpacing)
    {
        this._spacing = spacing;
    }

    double spacing() => _spacing;

    void spacing(double value)
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
