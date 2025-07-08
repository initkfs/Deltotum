module api.subs.ele.circuit;

import api.dm.gui.controls.containers.base.typed_container : TypedContainer;
import api.dm.gui.controls.control : Control;
import api.subs.ele.components;

/**
 * Authors: initkfs
 */

class Circuit : TypedContainer!Component
{
    this()
    {
        import api.dm.kit.sprites2d.layouts.managed_layout : ManagedLayout;

        layout = new ManagedLayout;
        layout.isAutoResize = true;
    }
}
