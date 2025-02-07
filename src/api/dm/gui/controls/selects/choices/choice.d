module api.dm.gui.controls.selects.choices.choice;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.switches.buttons.button : Button;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.selects.base_selector : BaseSelector;
import api.dm.gui.controls.texts.text_area : TextArea;
import api.dm.gui.controls.popups.menus.popup_menu : PopupMenu;
import api.dm.gui.controls.switches.buttons.navigate_button : NavigateButton, NavigateDirection;

import api.dm.gui.controls.containers.vbox : VBox;

/**
 * Authors: initkfs
 */
class Choice(T) : BaseSelector!T
{
    Button prevButton;

    bool isCreatePrevButton = true;
    Button delegate(Button) onNewPrevButton;
    void delegate(Button) onConfiguredPrevButton;
    void delegate(Button) onCreatedPrevButton;

    Button nextButton;

    bool isCreateNextButton = true;
    Button delegate(Button) onNewNextButton;
    void delegate(Button) onConfiguredNextButton;
    void delegate(Button) onCreatedNextButton;

    Text label;
    bool isCreateLabel = true;
    Text delegate(Text) onNewLabel;
    void delegate(Text) onConfiguredLabel;
    void delegate(Text) onCreatedLabel;

    dstring delegate(T) itemToTextConverter;

    Text searchField;
    bool isCreateSearchField;
    Text delegate(Text) onNewSearchField;
    void delegate(Text) onConfiguredSearchField;
    void delegate(Text) onCreatedSearchField;

    PopupMenu!T popupMenu;

    bool isCreatePopupMenu = true;
    PopupMenu!T delegate(PopupMenu!T) onNewPopupMenu;
    void delegate(PopupMenu!T) onConfiguredPopupMenu;
    void delegate(PopupMenu!T) onCreatedPopupMenu;

    protected
    {
        size_t selectedIndex;
        bool isSearchFromField;
    }

    T[] items;

    this()
    {
        import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

        layout = new HLayout;
        layout.isAutoResize = true;
        layout.isAlignY = true;
        isBorder = true;
        id = "choice";
    }

    override void initialize()
    {
        super.initialize;

        if (!itemToTextConverter)
        {
            itemToTextConverter = (item) {
                dstring text;
                static if (is(T : dstring))
                {
                    text = item;
                }
                else
                {
                    import std.conv : to;

                    text = item.to!dstring;
                }

                if (text.length > 0)
                {
                    return text;
                }

                //TODO placeholder
                return "[empty]";
            };
        }
    }

    final void isCreateSelectButtons(bool value)
    {
        isCreatePrevButton = value;
        isCreateNextButton = value;
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadChoiceTheme;
    }

    void loadChoiceTheme()
    {
        //loadControlSizeTheme;
    }

    override void create()
    {
        super.create;

        if (!popupMenu && isCreatePopupMenu)
        {
            auto menu = newPopupMenu;
            popupMenu = !onNewPopupMenu ? menu : onNewPopupMenu(menu);

            popupMenu.onFocusExit ~= (ref e) {
                if (popupMenu.isVisible)
                {
                    popupMenu.hide;
                }

                if (isSearchFromField)
                {
                    isSearchFromField = false;
                    if (popupMenu && popupMenu.menuList)
                    {
                        popupMenu.menuList.onRow((row) {
                            row.showForLayout;
                            return true;
                        });
                    }
                }
            };

            if (onConfiguredPopupMenu)
            {
                onConfiguredPopupMenu(popupMenu);
            }

            addCreate(popupMenu);

            popupMenu.menuList.onChangeOldNew ~= (oldRow, newRow) {
                assert(newRow);
                auto newItem = newRow.item;
                setSelected(newItem);
            };

            assert(sceneProvider);
            sceneProvider().controlledSprites ~= menu;

            if (onCreatedPopupMenu)
            {
                onCreatedPopupMenu(popupMenu);
            }
        }

        onPointerPress ~= (ref e) { showPopup; };

        if (isCreateNextButton || isCreatePrevButton)
        {
            auto prevNextContainer = new VBox;
            prevNextContainer.isAlignX = true;

            addCreate(prevNextContainer);

            if (!prevButton && isCreatePrevButton)
            {
                auto b = newButton(NavigateDirection.toTop);
                prevButton = !onNewPrevButton ? b : onNewPrevButton(b);

                prevButton.onAction ~= (ref e) {
                    selectPrev;
                    if (popupMenu && popupMenu.isVisible)
                    {
                        popupMenu.hide;
                    }
                };

                if (onConfiguredPrevButton)
                {
                    onConfiguredPrevButton(prevButton);
                }

                prevNextContainer.addCreate(prevButton);

                if (onCreatedPrevButton)
                {
                    onCreatedPrevButton(prevButton);
                }
            }

            if (!nextButton && isCreateNextButton)
            {
                auto b = newButton(NavigateDirection.toBottom);
                nextButton = !onNewNextButton ? b : onNewNextButton(b);

                nextButton.onAction ~= (ref e) {
                    selectNext;
                    if (popupMenu && popupMenu.isVisible)
                    {
                        popupMenu.hide;
                    }
                };

                if (onConfiguredNextButton)
                {
                    onConfiguredNextButton(nextButton);
                }

                prevNextContainer.addCreate(nextButton);

                if (onCreatedNextButton)
                {
                    onCreatedNextButton(nextButton);
                }
            }

        }

        if (!label && isCreateLabel)
        {
            auto l = newLabel;
            label = !onNewLabel ? l : onNewLabel(l);

            if (onConfiguredLabel)
            {
                onConfiguredLabel(label);
            }

            addCreate(label);

            if (onCreatedLabel)
            {
                onCreatedLabel(label);
            }
        }

        if (!searchField && isCreateSearchField && popupMenu)
        {
            auto sf = newSearchField;

            searchField = !onNewSearchField ? sf : onNewSearchField(sf);

            searchField.isEditable = true;

            searchField.onKeyPress ~= (ref e) {
                if (!popupMenu || !itemToTextConverter)
                {
                    return;
                }
                assert(popupMenu.menuList);

                if (!isSearchFromField)
                {
                    isSearchFromField = true;
                }

                const searchText = searchField.text;
                if (searchText.length == 0)
                {
                    return;
                }

                import std.algorithm.searching : startsWith;

                popupMenu.menuList.onRow((row) {
                    const itemText = itemToTextConverter(row.item);
                    if (!itemText.startsWith(searchText))
                    {
                        row.hideForLayout;
                    }
                    else
                    {
                        if (!row.isVisible)
                        {
                            row.showForLayout;
                        }
                    }
                    return true;
                });
            };

            if (onConfiguredSearchField)
            {
                onConfiguredSearchField(searchField);
            }

            popupMenu.addCreate(searchField, 0);

            searchField.enablePadding;

            if (onCreatedSearchField)
            {
                onCreatedSearchField(searchField);
            }
        }

        padding = theme.controlPadding.left / 2;
    }

    void togglePopup()
    {
        if (!popupMenu)
        {
            return;
        }
        if (popupMenu.isVisible)
        {
            popupMenu.hide;
            return;
        }

        showPopup;
    }

    void showPopup()
    {
        if (popupMenu && !popupMenu.isVisible)
        {
            if (popupMenu.width < width)
            {
                popupMenu.width = width;
            }

            auto newX = boundsRect.middleX - popupMenu.halfWidth;
            auto newY = boundsRect.bottom;

            popupMenu.show(newX, newY);

            if (!popupMenu.isFocus)
            {
                popupMenu.focus;
            }
        }
    }

    Button newButton(NavigateDirection direction)
    {
        return new NavigateButton(direction);
    }

    Text newLabel()
    {
        return new Text;
    }

    Text newSearchField()
    {
        return new Text("Search");
    }

    override void onRemoveFromParent()
    {
        if (popupMenu && sceneProvider)
        {
            auto isRemove = sceneProvider().removeControlled(popupMenu);
            assert(isRemove);
        }
    }

    PopupMenu!T newPopupMenu()
    {
        return new PopupMenu!T;
    }

    void fill(dstring[] newItems)
    {
        if (!isCreated)
        {
            throw new Exception("Control not created");
        }

        items = newItems;

        if (items.length == 0)
        {
            return;
        }

        if (popupMenu)
        {
            popupMenu.menuList.fill(items);
        }

        selectFirst;
    }

    bool hasItem(T target, out size_t index)
    {
        foreach (i, item; items)
        {
            static if (__traits(compiles, target is item))
            {
                if (target is item)
                {
                    index = i;
                    return true;
                }
            }
            else
            {
                if (target == item)
                {
                    index = i;
                    return true;
                }
            }
        }

        return false;
    }

    protected bool setSelectedWithIndex(size_t index, T newItem, bool isTriggerListeners = true)
    {
        if (!selectListIndex(index))
        {
            return false;
        }

        current(newItem, isTriggerListeners);
        setSelectedText(current);
        return true;
    }

    bool setSelected(T newItem, bool isTriggerListeners = true)
    {
        static if (__traits(compiles, newItem is current))
        {
            if (newItem is current)
            {
                return false;
            }
        }
        else
        {
            if (newItem == current)
            {
                return false;
            }
        }

        size_t index;
        if (!hasItem(newItem, index))
        {
            return false;
        }

        return setSelectedWithIndex(index, newItem, isTriggerListeners);
    }

    bool setSelectedIndex(size_t newIndex, bool isTriggerListeners = true)
    {
        if (newIndex >= items.length)
        {
            return false;
        }
        auto item = items[newIndex];
        return setSelectedWithIndex(newIndex, item, isTriggerListeners);
    }

    bool selectNext()
    {
        if (items.length == 0)
        {
            return false;
        }

        selectedIndex++;
        if (selectedIndex >= items.length)
        {
            selectedIndex = 0;
        }
        return setSelectedIndex(selectedIndex);
    }

    bool selectPrev()
    {
        if (items.length == 0)
        {
            return false;
        }

        if (selectedIndex == 0)
        {
            selectedIndex = items.length;
        }

        selectedIndex--;
        return setSelectedIndex(selectedIndex);
    }

    protected void setSelectedText(T item)
    {
        assert(label);
        assert(itemToTextConverter);
        label.text = itemToTextConverter(item);
    }

    protected bool selectListIndex(size_t index)
    {
        if (popupMenu && index < items.length)
        {
            if (auto isChange = popupMenu.menuList.selectByIndex(index, isTriggerListeners:
                    false))
            {
                return true;
            }
        }

        return false;
    }

    bool selectFirst()
    {
        if (items.length == 0)
        {
            return false;
        }

        return setSelectedIndex(0);
    }
}
