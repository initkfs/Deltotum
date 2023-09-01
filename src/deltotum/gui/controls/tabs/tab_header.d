module deltotum.gui.controls.tabs.tab_header;

import deltotum.gui.controls.control : Control;
import deltotum.gui.controls.texts.text : Text;
import deltotum.kit.sprites.layouts.hlayout : HLayout;
import deltotum.gui.controls.tabs.tab : Tab;
import deltotum.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
class TabHeader : Control
{

    Tab[] tabs;

    this(double tabSpacing = 5)
    {
        layout = new HLayout(tabSpacing);
        layout.isAutoResize = true;
        layout.isAlignY = true;
    }

    override void initialize(){
        super.initialize;
        enablePadding;
    }

    override void add(Sprite[] sprites)
    {
        foreach (s; sprites)
        {
            add(s);
        }
    }

    override void add(Sprite obj, long index = -1)
    {
        super.add(obj, index);
        if (auto tab = cast(Tab) obj)
        {
            addTab(tab);
        }
    }

    protected bool addTab(Tab newTab)
    {
        foreach (Tab t; tabs)
        {
            if (t is newTab)
            {
                return false;
            }
        }

        tabs ~= newTab;
        return true;
    }
}
