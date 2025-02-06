module api.dm.gui.controls.containers.center_box;

import api.dm.gui.controls.containers.container : Container;

/**
 * Authors: initkfs
 */
class CenterBox : Container
{
    this()
    {
        import api.dm.kit.sprites2d.layouts.center_layout : CenterLayout;

        layout = new CenterLayout;
        layout.isAutoResize = true;
    }
}
