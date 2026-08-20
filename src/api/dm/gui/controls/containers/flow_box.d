module api.dm.gui.controls.containers.flow_box;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.containers.container : Container;
import api.dm.kit.sprites2d.layouts.flow_layout : FlowLayout;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;

/**
 * Authors: initkfs
 */
class FlowBox : Container
{
    this(float hgap = 5, float vgap = 0, bool isAutoResize = false, bool isLayout = true, Control[] children = null)
    {
        super(() {
            import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

            auto layout = new FlowLayout(hgap, vgap);
            layout.isAutoResize = isAutoResize;
            return layout;
        }, isLayout, null, children);
    }
}
