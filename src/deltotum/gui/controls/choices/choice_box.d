module deltotum.gui.controls.choices.choice_box;

import deltotum.kit.sprites.sprite : Sprite;
import deltotum.gui.controls.control : Control;
import deltotum.gui.controls.buttons.button : Button;
import deltotum.gui.controls.texts.text : Text;
import deltotum.gui.containers.typed_container : TypedContainer;
import deltotum.gui.controls.texts.text_area : TextArea;

import deltotum.gui.containers.vbox : VBox;

class ChoiceItem : Sprite
{
    Button label;

    void delegate() onChoice;

    this()
    {
        import deltotum.kit.sprites.layouts.horizontal_layout : HorizontalLayout;

        layout = new HorizontalLayout(0);
        layout.isAutoResize(true);
        layout.isAlignX = true;
        isHGrow = true;
    }

    override void create()
    {
        super.create;

        label = new Button;
        label.isHGrow = true;
        addCreate(label);

        label.onAction = (e) {
            if (onChoice)
            {
                onChoice();
            }
        };
    }
}

/**
 * Authors: initkfs
 */
class ChoiceBox : TypedContainer!ChoiceItem
{
    protected
    {
        Text label;
        Button button;

        VBox choiceList;

        ChoiceItem selected;
        size_t selectedIndex;
        TextArea searchField;
    }

    this()
    {
        import deltotum.kit.sprites.layouts.horizontal_layout : HorizontalLayout;

        layout = new HorizontalLayout(5);
        layout.isAutoResize(true);
        layout.isAlignY = true;
        isBorder = true;
    }

    override void create()
    {
        super.create;

        import deltotum.gui.containers.vbox : VBox;

        auto prevNextContainer = new VBox(0);
        auto prevButton = new Button("▲", 10, 10);
        prevButton.onAction = (e) { selectPrev; };
        prevButton.isBackground = false;
        auto nextButton = new Button("▼", 10, 10);
        nextButton.onAction = (e) { selectNext; };
        nextButton.isBackground = false;
        addCreate(prevNextContainer);
        prevNextContainer.addCreate(prevButton);
        prevNextContainer.addCreate(nextButton);

        label = new Text("----");
        label.setGrow(true);
        addCreate(label);

        button = new Button("▼");
        button.isBackground = true;
        button.width = 50;
        button.isVGrow = true;
        addCreate(button);

        button.onAction = (e) { toggleChoiceList; };

        choiceList = new VBox(2);
        choiceList.id = "choice_box_list";
        choiceList.isAlignX = true;
        choiceList.onFocusOut = (e) {
            if (choiceList.isVisible)
            {
                choiceList.isVisible = false;
            }
            return false;
        };

        auto oldOnFocusOut = onFocusOut;
        onFocusOut = (e) {
            if (oldOnFocusOut && oldOnFocusOut(e))
            {
                return true;
            }

            if (choiceList.isVisible)
            {
                const listBounds = choiceList.bounds;
                if (listBounds.contains(input.mousePos))
                {
                    return false;
                }

                choiceList.isVisible = false;
            }

            return false;
        };

        choiceList.isBorder = true;
        choiceList.isLayoutManaged = false;
        addCreate(choiceList);
        choiceList.isResizedByParent = false;
        choiceList.isVisible = false;

        searchField = new TextArea();
        searchField.width = choiceList.width;
        searchField.isResizedByParent = true;
        searchField.isFocusable = true;
        searchField.isHGrow = true;
        choiceList.addCreate(searchField);
        searchField.textView.text = "";
        searchField.scroll.isVisible = false;

        //TODO hack
        searchField.textView.maxWidth = double.max;
        
        auto oldKeyTyped = searchField.onKeyDown;
        searchField.onKeyDown = (e){
            if(oldKeyTyped && oldKeyTyped(e)){
                //return true;
            }

            fillItemList;
            choiceList.applyLayout;

            return false;
        };

    }

    protected void toggleChoiceList()
    {
        choiceList.width = width;
        choiceList.x = x;
        choiceList.y = bounds.bottom;

        foreach (item; items)
        {
            if (item.label.isSelected)
            {
                item.label.isSelected = false;
            }
        }

        if (selected)
        {
            foreach (item; items)
            {
                if (selected is item)
                {
                    item.label.isSelected = true;
                }
            }
        }

        choiceList.isVisible = !choiceList.isVisible;

        //TODO fix bug
        choiceList.applyLayout;
    }

    void fill(dstring[] list)
    {
        items = [];

        if (list.length == 0)
        {
            return;
        }

        foreach (s; list)
            (dstring s) {
            import deltotum.gui.containers.hbox : HBox;

            auto choiceListRow = new ChoiceItem;
            choiceListRow.width = choiceList.width - choiceList.padding.width;
            build(choiceListRow);
            choiceListRow.initialize;
            choiceListRow.create;
            items ~= choiceListRow;
            choiceListRow.label.text = s;
            choiceListRow.onChoice = () {
                selectItem(choiceListRow);
                toggleChoiceList;
            };
        }(s);

        fillItemList;

        if (items.length > 0)
        {
            selectItem(items[0]);
        }
    }

    protected void fillItemList()
    {
        scope Sprite[] removed;
        foreach (oldItem; choiceList.children)
        {
            if (cast(ChoiceItem) oldItem)
            {
                removed ~= oldItem;
            }
        }

        if (removed.length > 0)
        {
            choiceList.remove(removed, false);
            choiceList.applyLayout;
        }

        foreach (item; items)
        {
            const searchText = searchField.textView.text;
            if (searchText.length > 0)
            {
                import std.algorithm.searching : startsWith;

                const itemText = item.label.text;
                if (!itemText.startsWith(searchText))
                {
                    continue;
                }
            }

            choiceList.addCreate(item);
        }
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
        return selectIndex(selectedIndex);
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
        return selectIndex(selectedIndex);
    }

    ChoiceItem find(dstring itemText)
    {
        if (itemText.length == 0)
        {
            return null;
        }

        foreach (item; choiceList.children)
        {
            if (auto cItem = cast(ChoiceItem) item)
            {
                if (cItem.label.text == itemText)
                {
                    return cItem;
                }
            }
        }
        return null;
    }

    ChoiceItem findItem(ChoiceItem item)
    {
        return find(item.label.text);
    }

    protected bool selectItem(ChoiceItem item)
    {
        if (item is selected)
        {
            return false;
        }

        import std.algorithm.searching : countUntil;

        auto mustBeSelectedIndex = items.countUntil(item);
        if (mustBeSelectedIndex < 0)
        {
            return false;
        }
        selectIndex(mustBeSelectedIndex);

        return true;
    }

    protected bool selectIndex(size_t i)
    {
        if (items.length == 0 || i >= items.length)
        {
            return false;
        }

        selectedIndex = i;
        selected = items[selectedIndex];
        label.text = selected.label.text;

        return true;
    }

    bool select(dstring itemText)
    {
        ChoiceItem existingItem = find(itemText);
        if (!existingItem)
        {
            return false;
        }

        return selectItem(existingItem);
    }

    bool select(ChoiceItem item)
    {
        return select(item.label.text);
    }
}
