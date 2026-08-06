module api.dm.gui.controls.selects.menus.dropdown_menu;

import api.dm.gui.controls.popups.base_popup : BasePopup;
import api.dm.gui.controls.control : Control;

/**
 * Authors: initkfs
 */

class DropDownMenu : BasePopup
{
    void delegate() onAction;

    this()
    {
        setVLayout;
        isBorder = true;
        isBackground = true;
    }

    override void create()
    {
        super.create;
        enablePadding;
    }

    void hideAction(Control control)
    {
        if (onAction)
        {
            onAction();
        }
        if (control.isHover)
        {
            control.endHover;
        }
        hide;
    }

    override void show(float x, float y)
    {
        const w = width - padding.width - 2;
        foreach (ch; children)
        {
            if (ch.width < w)
            {
                ch.width = w;
            }
        }
        super.show(x, y);
    }

    void addCheckItem(dstring text, void delegate(bool oldv, bool newv) onAction)
    {
        import api.dm.gui.controls.switches.checks.check : Check;

        auto check = new Check(text);
        //TODO precompute
        check.resize(5, 5);
        check.isCreateInteractions = true;
        check.onChangeOldNew ~= (old, newv) {
            hideAction(check);
            if (onAction)
            {
                onAction(old, newv);
            }
        };
        check.isEnablePadding = false;
        addCreate(check);
    }

    void addButton(dstring text, void delegate() onAction)
    {
        import api.dm.gui.controls.texts.text : Text;
        import api.dm.gui.controls.switches.buttons.button : Button;

        auto item = new Button(text);
        item.isBorder = false;
        item.isBackground = false;
        item.isEnablePadding = false;
        item.onPointerPress ~= (ref e) {
            hideAction(item);
            if (onAction)
            {
                onAction();
            }
        };
        addCreate(item);
        if (item.layout)
        {
            item.layout.isAlignY = true;
            item.layout.isAlignOneChild = false;
        }
    }

    void addSep()
    {
        import api.dm.gui.controls.separators.hsep : HSep;

        auto sep = new HSep;
        addCreate(sep);
    }

}
