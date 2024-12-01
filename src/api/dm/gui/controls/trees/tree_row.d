module api.dm.gui.controls.trees.tree_row;

import api.dm.kit.sprites.sprites2d.sprite2d: Sprite2d;
import api.dm.gui.containers.container : Container;
import api.dm.gui.controls.texts.text: Text;

import api.dm.gui.controls.trees.tree_item: TreeItem;

/**
 * Authors: initkfs
 */
class TreeRow(T) : Container
{
    TreeItem!T item;
    TreeRow!T[] children;

    void delegate() onSelected;
    void delegate() onExpand;

    size_t treeLevel;

    bool isExpand;
    bool isFirst;
    bool isLast;

    dstring expandSymbol = "▶";
    dstring hidingSymbol = "▼";

    Text itemLabel;
    Text levelLabel;
    Text expandButton;

    this(TreeItem!T item, bool isExpand = false, size_t treeLevel = 0)
    {
        import api.dm.kit.sprites.sprites2d.layouts.hlayout : HLayout;

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

    protected void setButtonText()
    {
        if (expandButton)
        {
            expandButton.text = isExpand ? hidingSymbol : expandSymbol;
        }
    }

    protected void toggleTreeBranch(TreeRow!T row, bool isExpandRow)
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
        import api.dm.gui.controls.texts.text : Text;
        import api.math.insets : Insets;

        //TODO recreate

        onPointerDown ~= (ref e) {
            if (onSelected)
            {
                onSelected();
            }
        };

        if (treeLevel > 0)
        {
            levelLabel = new Text("");
            levelLabel.isFocusable = false;

            auto level = treeLevel;
            if (level > 0)
            {
                foreach (l; 0 .. level - 1)
                {
                    levelLabel.text = levelLabel.text ~ "│";
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
            expandButton.onPointerDown ~= (ref e) {
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
        else static if (is(T : Sprite2d))
        {
            auto sprite = item.item;
            string text = sprite.id.length > 0 ? sprite.id : sprite.classNameShort;
        }

        itemLabel = new Text(text);
        itemLabel.isFocusable = false;
        //if (!expandButton)
        //{
        //enum buttonWidthOffset = 5;
        //t.margin = Insets(0, 0, 0, buttonWidthOffset * treeLevel);
        //}
        addCreate(itemLabel);
        itemLabel.padding = Insets(0);

        if (item.children.length > 0)
        {
            expand(isExpand);
        }
    }

    //TODO hack, remove duplication
    void setLastRowLabel()
    {
        if(!levelLabel){
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

        levelLabel.text = text;
    }
}


