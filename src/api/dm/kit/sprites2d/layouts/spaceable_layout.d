module api.dm.kit.sprites2d.layouts.spaceable_layout;

import api.dm.kit.sprites2d.layouts.managed_layout : ManagedLayout;

/**
 * Authors: initkfs
 */
class SpaceableLayout : ManagedLayout
{
    enum DefaultSpacing = -1;

    double spacing = 0;

    this(double spacing = DefaultSpacing) pure
    {
        this.spacing = spacing;
    }
}
