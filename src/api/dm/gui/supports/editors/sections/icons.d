module api.dm.gui.supports.editors.sections.icons;

import api.dm.gui.controls.control : Control;
import api.math.geom2.rect2 : Rect2f;

import std.stdio;

/**
 * Authors: initkfs
 */
class Icons : Control
{
    this()
    {
        import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

        // layout = new HLayout;
        // layout.isAutoResize = true;
        // isBackground = false;
        // layout.isAlignY = false;
    }

    override void initialize()
    {
        super.initialize;
        enablePadding;
    }

    override void create()
    {
        super.create;

        import api.dm.gui.controls.containers.hbox : HBox;

        //auto root = new HBox;
        //addCreate(root);

        import IconName = api.dm.gui.themes.icons.pack_bootstrap;

        float nextX = 0;
        float nextY = 0;

        import std: replace;

        foreach (i, iconCode; IconName.syms)
        {
            auto icon = createIcon(iconCode);
            icon.isLayoutManaged = false;
            addCreate(icon);
            auto newX = nextX + icon.width;
            if (newX > window.width)
            {
                nextY++;
                nextX = 0;
            }else {
                nextX = newX;
            }
            icon.x = nextX;
            icon.y = nextY * icon.height;
        }
    }
}
