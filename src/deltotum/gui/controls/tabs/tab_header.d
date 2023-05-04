module deltotum.gui.controls.tabs.tab_header;

import deltotum.gui.containers.container : Container;
import deltotum.gui.controls.texts.text : Text;
import deltotum.kit.sprites.layouts.horizontal_layout : HorizontalLayout;
import deltotum.gui.controls.tabs.tab : Tab;
import deltotum.kit.sprites.sprite : Sprite;

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

    override void add(Sprite obj, long index = -1)
    {
        super.add(obj, index);
        if (auto tab = cast(Tab) obj)
        {
            //TODO check duplicates
            tabs ~= tab;
        }
    }
}
