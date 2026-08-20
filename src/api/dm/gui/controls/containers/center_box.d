module api.dm.gui.controls.containers.center_box;

import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.control : Control;

/**
 * Authors: initkfs
 */
class CenterBox : Container
{
    this(bool isAutoResize = true, bool isLayout = true, Control[] children = null)
    {
        super(() {

            import api.dm.kit.sprites2d.layouts.center_layout : CenterLayout;

            layout = new CenterLayout;
            layout.isAutoResize = isAutoResize;
            return layout;
        }, isLayout, null, children);
    }
}
