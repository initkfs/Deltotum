module api.dm.kit.sprites.layouts.spaceable_layout;

import api.dm.kit.sprites.layouts.managed_layout : ManagedLayout;

/**
 * Authors: initkfs
 */
class SpaceableLayout : ManagedLayout
{
    double spacing = 0;

    this(double spacing = 0) pure
    {
        this.spacing = spacing;
    }
}
