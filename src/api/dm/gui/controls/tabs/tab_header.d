module api.dm.gui.controls.tabs.tab_header;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.texts.text : Text;
import api.dm.kit.sprites.layouts.hlayout : HLayout;
import api.dm.gui.controls.tabs.tab : Tab;
import api.dm.kit.sprites.sprite : Sprite;

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

    override void initialize()
    {
        super.initialize;
        enablePadding;
    }

    alias add = Control.add;

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

        import api.core.utils.types : castSafe;

        if (auto tab = obj.castSafe!Tab)
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
