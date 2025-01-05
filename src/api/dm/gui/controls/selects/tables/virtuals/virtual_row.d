module api.dm.gui.controls.selects.tables.virtuals.virtual_row;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.containers.container : Container;
import api.dm.gui.controls.control : Control;

import api.dm.gui.controls.selects.tables.base_table_row : BaseTableRow;
import api.math.geom2.vec2 : Vec2d;

/**
 * Authors: initkfs
 */
class VirtualRow(T) : BaseTableRow!T
{
    void delegate(bool oldValue, bool newValue) onSelectedOldNewValue;

    override void loadTheme()
    {
        super.loadTheme;
    }

    override void create()
    {
        super.create;
    }
}
