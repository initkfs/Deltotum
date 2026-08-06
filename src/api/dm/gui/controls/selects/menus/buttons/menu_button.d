module api.dm.gui.controls.selects.menus.buttons.menu_button;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.switches.buttons.button : Button;
import api.dm.gui.controls.popups.menus.popup_menu : PopupMenu;
import api.dm.gui.controls.selects.menus.dropdown_menu : DropDownMenu;

/**
 * Authors: initkfs
 */

class MenuButton : Control
{
    Button menuButton;

    DropDownMenu popupMenu;
    size_t menuLevel;

    protected
    {
        dstring _text;
    }

    this(dstring text = "Menu")
    {
        setHLayout(true, 0);
        this._text = text;
    }

    override void create()
    {
        super.create;

        popupMenu = new DropDownMenu;
        addCreate(popupMenu);

        scene.addTaken(popupMenu);

        popupMenu.onFocusExit ~= (ref e) {
            if (popupMenu.isVisible)
            {
                popupMenu.hide;
            }
        };

        menuButton = newButton;
        menuButton.isHGrow = true;
        _text = null;
        menuButton.isEnablePadding = false;
        addCreate(menuButton);

        menuButton.onAction ~= (ref e) { showPopup; };
    }

    Button newButton() => new Button(_text);

    void showPopup()
    {
        if (popupMenu && !popupMenu.isVisible)
        {
            const isRoot = menuLevel == 0;
            float newX, newY;
            if (isRoot)
            {
                newX = boundsRect.x;
                newY = boundsRect.bottom;
            }
            else
            {
                if (parent)
                {
                    const parentBounds = parent.boundsRect;
                    newX = parentBounds.right;
                    newY = boundsRect.y;
                }
            }

            popupMenu.show(newX, newY);

            if (!popupMenu.isFocus)
            {
                popupMenu.focus;
            }
        }
    }

    typeof(this) addSubMenu(dstring newText)
    {
        auto subMenu = new class MenuButton
        {
            this()
            {
                super(newText);
            }

            override Button newButton()
            {
                auto btn = new Button(newText);
                btn.isBorder = false;
                btn.isBackground = false;
                return btn;
            }
        };
        subMenu.menuLevel++;
        popupMenu.addCreate(subMenu);
        popupMenu.onAction = () { popupMenu.hide; };
        return subMenu;
    }

    void addCheckItem(dstring text, void delegate(bool oldv, bool newv) onAction)
    {
        popupMenu.addCheckItem(text, onAction);
    }

    void addButton(dstring text, void delegate() onAction)
    {
        popupMenu.addButton(text, onAction);
    }

    void addSep()
    {
        popupMenu.addSep;
    }

}
