module deltotum.ui.controls.tabs.tab_header;

import deltotum.ui.containers.container : Container;
import deltotum.ui.controls.texts.text : Text;
import deltotum.toolkit.display.layouts.horizontal_layout : HorizontalLayout;
import deltotum.ui.controls.tabs.tab : Tab;
import deltotum.toolkit.display.display_object : DisplayObject;

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
