module dm.gui.controls.tabs.tab_header;

import dm.gui.controls.control : Control;
import dm.gui.controls.texts.text : Text;
import dm.kit.sprites.layouts.hlayout : HLayout;
import dm.gui.controls.tabs.tab : Tab;
import dm.kit.sprites.sprite : Sprite;

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

        import dm.core.utils.type_util : castSafe;

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
