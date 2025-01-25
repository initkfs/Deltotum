module api.dm.gui.controls.selects.time_pickers.dialogs.choosers.base_circular_time_chooser;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.selects.time_pickers.dialogs.choosers.base_time_chooser : BaseTimeChooser;
import api.dm.gui.controls.containers.circle_box : CircleBox;

/**
 * Authors: initkfs
 */
abstract class BaseCircularTimeChooser : BaseTimeChooser
{
    double radius = 0;
    double startAngleDeg = 0;

    override void loadTheme(){
        super.loadTheme;
        loadBaseCircularTimeChooserTheme;
    }

    void loadBaseCircularTimeChooserTheme(){
        if(radius == 0){
            radius = theme.meterThumbDiameter;
        }
    }

    CircleBox newCircleBox()
    {
        return newCircleBox(radius, startAngleDeg);
    }

    CircleBox newCircleBox(double radius, double angleDeg)
    {
        assert(radius > 0);
        auto box = new CircleBox(radius, angleDeg);
        return box;
    }
}
