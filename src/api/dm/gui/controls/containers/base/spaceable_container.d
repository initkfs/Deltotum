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
        double _spacing;
    }

    this(double spacing = SpaceableLayout.DefaultSpacing)
    {        
        this._spacing = spacing;
    }

    double spacing()
    {
        return _spacing;
    }

    void spacing(double value)
    {
        _spacing = value;
    }

    override void enableInsets()
    {
        //TODO lazy flag
        super.enableInsets;
        enableSpacing;
    }

    void enableSpacing()
    {
        if (!hasGraphics || !theme)
        {
            throw new Exception(
                "Unable to enable spacing: graphic or theme is null. Perhaps the component is not built correctly");
        }
        const value = theme.controlSpacing;
        spacing = value;
    }

}
