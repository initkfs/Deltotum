module dm.gui.containers.base.spaceable_container;

import dm.gui.containers.container : Container;

/**
 * Authors: initkfs
 */
class SpaceableContainer : Container
{
    private
    {
        double _spacing;
    }

    this(double spacing = 0) pure
    {
        import std.exception : enforce;
        import std.conv : text;

        enforce(spacing >= 0, text("Spacing must be positive value or 0: ", spacing));
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
        if (!hasGraphics || !graphics.theme)
        {
            throw new Exception(
                "Unable to enable spacing: graphic or theme is null. Perhaps the component is not built correctly");
        }
        const value = graphics.theme.controlSpacing;
        spacing = value;
    }

}
