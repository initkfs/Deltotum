module api.dm.gui.controls.selects.selectable;

import api.dm.gui.controls.control : Control;

/**
 * Authors: initkfs
 */
interface Selectable
{
    bool isSelected();
    void isSelected(bool value);
}
