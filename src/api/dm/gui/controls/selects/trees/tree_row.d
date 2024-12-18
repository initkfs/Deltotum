module api.dm.gui.controls.selects.trees.tree_row;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.containers.container : Container;
import api.dm.gui.controls.texts.text : Text;

import api.dm.gui.controls.selects.trees.tree_item : TreeItem;

/**
 * Authors: initkfs
 */
class TreeRow(T) : Container
{
    TreeItem!T rowItem;

    TreeRow!T parentRow;
    TreeRow!T[] childrenRows;

    void delegate(bool oldValue, bool newValue) onSelectedOldNewValue;
    void delegate(bool oldValue, bool newValue) onExpandOldNewValue;

    bool isSelectable = true;

    size_t treeLevel;

    protected
    {
        bool isSelected;
        bool isExpand;
        bool isFirst;
        bool isLast;
    }

    import GuiSymbols = api.dm.gui.gui_text_symbols;

    dstring expandSymbol;
    dstring hidingSymbol;

    bool isExpandable = true;

    Text itemText;
    bool isCreateItemText = true;
    Text delegate(Text) onNewItemText;
    void delegate(Text) onCreatedItemText;

    dstring delegate(T) itemTextProvider;

    Text levelGraphics;
    bool isCreateLevelGraphics = true;
    Text delegate(Text) onNewLevelGraphics;
    void delegate(Text) onCreatedLevelGraphics;

    Text expandGraphics;
    bool isCreateExpandGraphics = true;
    Text delegate(Text) onNewExpandGraphics;
    void delegate(Text) onCreatedExpandGraphics;

    this(TreeItem!T rowItem, bool isExpand = false, size_t treeLevel = 0)
    {
        import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

        layout = new HLayout;
        layout.isAutoResize = true;

        this.rowItem = rowItem;
        this.treeLevel = treeLevel;
        this.isExpand = isExpand;
    }

    override void initialize()
    {
        super.initialize;

        if (!itemTextProvider)
        {
            itemTextProvider = (T item) {
                import std.conv : to;

                return item.to!dstring;
            };
        }
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadTreeRowTheme;
    }

    void loadTreeRowTheme()
    {
        if (expandSymbol.length == 0)
        {
            import GuiSymbols = api.dm.gui.gui_text_symbols;

            expandSymbol = GuiSymbols.expandSymbol;
        }

        if (hidingSymbol.length == 0)
        {
            import GuiSymbols = api.dm.gui.gui_text_symbols;

            hidingSymbol = GuiSymbols.hidingSymbol;
        }
    }

    override void create()
    {
        super.create;
        import api.dm.gui.controls.texts.text : Text;
        import api.math.insets : Insets;

        if (treeLevel > 0 && !levelGraphics && isCreateLevelGraphics)
        {
            auto nlg = newLevelGraphics;
            levelGraphics = !onNewLevelGraphics ? nlg : onNewLevelGraphics(nlg);

            levelGraphics.padding = Insets(0);

            addCreate(levelGraphics);
            if (onCreatedLevelGraphics)
            {
                onCreatedLevelGraphics(levelGraphics);
            }

            setTreeLevel(levelGraphics);
        }

        //TODO child !is null
        if (rowItem.childrenItems.length > 0 && !expandGraphics && isCreateExpandGraphics)
        {
            auto eg = newExpandGraphics;
            expandGraphics = !onNewExpandGraphics ? eg : onNewExpandGraphics(eg);

            expandGraphics.padding = Insets(0);

            addCreate(expandGraphics);
            if (onCreatedExpandGraphics)
            {
                onCreatedExpandGraphics(expandGraphics);
            }

            expandGraphics.onPointerPress ~= (ref e) {
                this.isExpand = !isExpand;
                setExpandGraphics;
                foreach (ch; childrenRows)
                {
                    toggleTreeBranch(ch, isExpand);
                }
            };
        }

        if (!itemText && isCreateItemText)
        {
            assert(itemTextProvider);
            auto text = itemTextProvider(rowItem.item);
            auto it = newItemText(text);
            itemText = !onNewItemText ? it : onNewItemText(it);

            itemText.padding = Insets(0);

            addCreate(itemText);
            if (onCreatedItemText)
            {
                onCreatedItemText(itemText);
            }
        }

        if (rowItem.childrenItems.length > 0)
        {
            expand(isExpand);
        }

        onPointerPress ~= (ref e) { toggleSelected; };
    }

    Text newLevelGraphics()
    {
        return new Text("");
    }

    Text newExpandGraphics()
    {
        return new Text("");
    }

    Text newItemText(dstring text)
    {
        return new Text(text);
    }

    bool expand() => isExpand;

    void expand(bool value)
    {
        //TODO remove overwriting
        isExpand = value;

        setExpandGraphics;

        isVisible = value;
        isManaged = value;
        isLayoutManaged = value;
    }

    protected void setTreeLevel(Text label)
    {
        auto level = treeLevel;
        if (level > 0)
        {
            foreach (l; 0 .. level - 1)
            {
                label.text = levelGraphics.text ~ "│";
            }
        }
        label.text = levelGraphics.text ~ "├";
    }

    protected void setExpandGraphics()
    {
        if (expandGraphics)
        {
            expandGraphics.text = isExpand ? hidingSymbol : expandSymbol;
        }
    }

    void toggleSelected()
    {
        toggleSelected(!isSelected);
    }

    void toggleSelected(bool newValue)
    {
        if (newValue == isSelected)
        {
            return;
        }
        auto oldValue = isSelected;
        isSelected = newValue;
        if (onSelectedOldNewValue)
        {
            onSelectedOldNewValue(oldValue, isSelected);
        }
    }

    protected void toggleTreeBranch(TreeRow!T row, bool isExpandRow)
    {
        row.expand(isExpandRow);
        if (row.childrenRows.length > 0)
        {
            foreach (ch; row.childrenRows)
            {
                toggleTreeBranch(ch, isExpandRow);
            }
        }
    }

    //TODO hack, remove duplication
    void setLastRowLabel()
    {
        if (!levelGraphics)
        {
            return;
        }

        dstring levelSymbol = "└";
        dstring text = levelSymbol;
        if (treeLevel > 0)
        {
            foreach (l; 0 .. treeLevel - 1)
            {
                text ~= levelSymbol;
            }
        }

        levelGraphics.text = text;
    }
}
