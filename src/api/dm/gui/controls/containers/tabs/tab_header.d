module api.dm.gui.controls.containers.tabs.tab_header;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.containers.tabs.tab : Tab;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;

/**
 * Authors: initkfs
 */
class TabHeader : Control
{
    //protected {
    Tab[] tabs;
    //}

    this(float tabSpacing = 1)
    {
        import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

        layout = new HLayout(tabSpacing);
        layout.isAutoResize = true;
        layout.isAlignY = true;
    }

    alias add = Control.add;

    override void add(Sprite2d obj, long index = -1)
    {
        super.add(obj, index);

        if (auto tab = cast(Tab) obj)
        {
            bool isAdd = addTab(tab);
            if (!isAdd)
            {
                throw new Exception("Failed to add tab: " ~ tab.toString);
            }
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
