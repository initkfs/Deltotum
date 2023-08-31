module deltotum.gui.controls.data.tree_table_view;

import deltotum.gui.controls.control : Control;
import deltotum.gui.containers.scroll_box : ScrollBox;
import deltotum.gui.containers.container : Container;
import deltotum.gui.containers.vbox : VBox;
import deltotum.gui.containers.hbox : HBox;
import deltotum.gui.containers.stack_box : StackBox;
import deltotum.gui.controls.sliders.hslider : HSlider;
import deltotum.gui.controls.sliders.vslider : VSlider;
import deltotum.kit.sprites.sprite : Sprite;
import deltotum.math.geom.insets : Insets;
import deltotum.math.shapes.rect2d : Rect2d;
import deltotum.gui.controls.buttons.button : Button;
import deltotum.gui.controls.texts.text : Text;

class TreeItem(T)
{
    T item;
    TreeItem!T[] children;

    this(T item, TreeItem!T[] children = null)
    {
        this.item = item;
        this.children = children;
    }
}

class TableRow(T) : Container
{
    TreeItem!T item;

    void delegate() onSelected;

    bool isExpand;
    size_t treeLevel;

    TableRow!T[] children;

    dstring expandSymbol = "▶";
    dstring hidingSymbol = "▼";

    Text expandButton;

    void delegate() onExpand;

    this(TreeItem!T item, bool isExpand = false, size_t treeLevel = 0)
    {
        import deltotum.kit.sprites.layouts.hlayout : HLayout;

        layout = new HLayout;
        layout.isAutoResize = true;
        this.item = item;
        this.treeLevel = treeLevel;
        this.isExpand = isExpand;
    }

    void expand(bool value)
    {
        //TODO remove overwriting
        isExpand = value;

        setButtonText;
        isVisible = value;
        isManaged = value;
        isLayoutManaged = value;
    }

    void setButtonText()
    {
        if (expandButton)
        {
            expandButton.text = isExpand ? hidingSymbol : expandSymbol;
        }
    }

    protected void toggleTreeBranch(TableRow!T row, bool isExpandRow)
    {
        row.expand(isExpandRow);
        if (row.children.length > 0)
        {
            foreach (ch; row.children)
            {
                toggleTreeBranch(ch, isExpandRow);
            }

        }
    }

    override void create()
    {
        super.create;
        import deltotum.gui.controls.texts.text : Text;
        import deltotum.math.geom.insets : Insets;

        onMouseDown = (ref e) {
            if (onSelected)
            {
                onSelected();
            }
        };

        if (treeLevel > 0)
        {
            enum levelMargin = 5;
            Text levelLabel = new Text("");
            levelLabel.isFocusable = false;

            auto level = treeLevel;
            if (level > 1)
            {
                foreach (l; 0 .. level - 1)
                {
                    levelLabel.text = levelLabel.text ~ "│ ";
                }
            }
            levelLabel.text = levelLabel.text ~ "├";

            addCreate(levelLabel);
            levelLabel.padding = Insets(0);
            //TODO copy texture;
            //levelLabel.opacity = 0.5;
        }

        //TODO child !is null
        if (item.children.length > 0)
        {
            expandButton = new Text("");
            expandButton.isFocusable = false;
            addCreate(expandButton);
            expandButton.padding = Insets(0);
            expandButton.onMouseDown = (ref e) {
                this.isExpand = !isExpand;
                setButtonText;
                foreach (ch; children)
                {
                    toggleTreeBranch(ch, isExpand);
                }
            };
        }

        static if (is(T : string))
        {
            string text = item.item;
        }
        //TODO for debug
        else static if (is(T : Sprite))
        {
            auto sprite = item.item;
            string text = sprite.id.length > 0 ? sprite.id : sprite.classNameShort;
        }

        auto t = new Text(text);
        t.isFocusable = false;
        //if (!expandButton)
        //{
        //enum buttonWidthOffset = 5;
        //t.margin = Insets(0, 0, 0, buttonWidthOffset * treeLevel);
        //}
        addCreate(t);
        t.padding = Insets(0);

        if (item.children.length > 0)
        {
            expand(isExpand);
        }
    }
}

/**
 * Authors: initkfs
 */
class TreeTableView(T) : ScrollBox
{
    TableRow!T[] rows;

    VBox rowContainer;

    void delegate(T oldItem, T newItem) onSelectedOldNew;

    T currentSelected;

    this()
    {
        isBorder = true;
    }

    override void create()
    {
        super.create;

        rowContainer = new VBox(0);
        setContent(rowContainer);
        rowContainer.padding = Insets(0);
    }

    void buildTree(Sprite root, TreeItem!T item, TableRow!T parent = null, size_t treeLevel = 0)
    {
        const canExpand = item.children.length > 0 ? true : false;
        auto row = new TableRow!T(item, canExpand, treeLevel);
        row.isExpand = true;
        if (parent)
        {
            parent.children ~= row;
        }
        root.addCreate(row);
        row.padding = Insets(0);
        row.onSelected = () {
            if (row is currentSelected)
            {
                return;
            }
            auto oldSelected = row.item.item;
            currentSelected = row.item.item;
            if (onSelectedOldNew)
            {
                onSelectedOldNew(oldSelected, currentSelected);
            }
        };
        if (item.children.length > 0)
        {
            treeLevel++;
            foreach (ch; item.children)
            {
                buildTree(root, ch, row, treeLevel);
            }
        }
    }

    bool clear()
    {
        if (rows.length > 0)
        {
            contentRoot.removeAll;
            rows = [];
            return true;
        }

        return false;
    }

    void fill(TreeItem!T[] items)
    {
        clear;

        foreach (TreeItem!T item; items)
        {
            buildTree(contentRoot, item);
        }
    }

    void fill(TreeItem!T item)
    {
        clear;
        buildTree(contentRoot, item);
    }
}
