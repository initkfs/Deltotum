module api.dm.gui.controls.containers.circle_box;

import api.dm.gui.controls.containers.container : Container;
import api.dm.kit.sprites2d.layouts.circle_layout: CircleLayout;

/**
 * Authors: initkfs
 */
class CircleBox : Container
{
    this(double radius = 80, double startAngle = 0)
    {
        auto newLayout = new CircleLayout(radius);
        newLayout.startAngle = startAngle;
        
        layout = newLayout;
        layout.isAutoResize = true;
    }
}
