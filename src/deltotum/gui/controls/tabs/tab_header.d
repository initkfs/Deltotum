module deltotum.gui.controls.tabs.tab_header;

import deltotum.gui.containers.container : Container;
import deltotum.gui.controls.texts.text : Text;
import deltotum.kit.display.layouts.horizontal_layout : HorizontalLayout;
import deltotum.gui.controls.tabs.tab : Tab;
import deltotum.kit.display.display_object : DisplayObject;

/**
 * Authors: initkfs
 */
class TabHeader : Container
{

    Tab[] tabs;

    this(double tabSpacing = 5)
    {
        this.layout = new HorizontalLayout(tabSpacing);
    }

    override void add(DisplayObject obj, long index = -1)
    {
        super.add(obj, index);
        if (auto tab = cast(Tab) obj)
        {
            //TODO check duplicates
            tabs ~= tab;
        }
    }
}
