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

    bool isExpand;
    size_t treeLevel;

    TableRow!T[] children;

    dstring expandSymbol = "▶";
    dstring hidingSymbol = "▼";

    Button expandButton;

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

        //TODO child !is null
        if (item.children.length > 0)
        {
            expandButton = new Button("", 10, 10);
            expandButton.margin = Insets(0, 0, 0, 5 * treeLevel);
            addCreate(expandButton);
            expandButton.onAction = (ref e) {
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
        if (!expandButton)
        {
            enum buttonWidthOffset = 5;
            t.margin = Insets(0, 0, 0, buttonWidthOffset * treeLevel);
        }
        addCreate(t);

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

    this()
    {
        isBorder = true;
    }

    override void create()
    {
        super.create;

        rowContainer = new VBox(0);
        setContent(rowContainer);
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
        if (item.children.length > 0)
        {
            treeLevel++;
            foreach (ch; item.children)
            {
                buildTree(root, ch, row, treeLevel);
            }
        }
    }

    void fill(TreeItem!T[] items)
    {
        foreach (TreeItem!T item; items)
        {
            buildTree(contentRoot, item);
        }
    }
}
