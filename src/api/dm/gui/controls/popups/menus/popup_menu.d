module api.dm.gui.controls.popups.menus.popup_menu;

import api.dm.gui.controls.popups.base_popup : BasePopup;
import api.dm.gui.controls.selects.tables.clipped.clipped_list : SimpleClippedList, newSimpleClippedList;

/**
 * Authors: initkfs
 */
class PopupMenu(T) : BasePopup
{

    SimpleClippedList!T menuList;

    bool isCreateMenuList = true;
    SimpleClippedList!T delegate(SimpleClippedList!T) onNewMenuList;
    void delegate(SimpleClippedList!T) onConfiguredMenuList;
    void delegate(SimpleClippedList!T) onCreatedMenuList;

    this()
    {
        super(isCreateLayout : false);

        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout;
        layout.isAutoResize = true;
        layout.isAlignX = true;
    }

    override void create()
    {
        super.create;

        if (!menuList)
        {
            auto list = newMenuList;
            menuList = !onNewMenuList ? list : onNewMenuList(list);

            if (onConfiguredMenuList)
            {
                onConfiguredMenuList(menuList);
            }

            addCreate(menuList);

            if (onCreatedMenuList)
            {
                onCreatedMenuList(menuList);
            }
        }
    }

    SimpleClippedList!T newMenuList()
    {
        auto list = newSimpleClippedList!T;
        return list;
    }
}
