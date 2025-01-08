module api.dm.gui.controls.selects.tables.clipped.trees.base_tree_table;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.selects.tables.clipped.base_clipped_table : BaseClippedTable;
import api.dm.gui.controls.selects.tables.base_table_column : BaseTableColumn;
import api.dm.gui.controls.selects.tables.base_table_row : BaseTableRow;
import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.selects.tables.clipped.trees.tree_item : TreeItem;
import api.dm.gui.controls.selects.tables.clipped.trees.tree_row : TreeRow;
import api.dm.gui.controls.containers.scroll_box : ScrollBox;

/**
 * Authors: initkfs
 */
class BaseTreeTable(T, TCol:
    BaseTableColumn!T, TRow:
    TreeRow!T) : BaseClippedTable!(T, TCol, TRow)
{

    TRow[] rows;

    protected
    {
        TRow currentSelected;
    }

    this(size_t columnCount)
    {
        super(columnCount);
    }

    protected void buildTree(
        Sprite2d root,
        TreeItem!T item,
        TreeRow!T parent = null,
        size_t treeLevel = 0, 
        size_t rowIndex,
        size_t rowLastIndex,
        )
    {
        const canExpand = item.childrenItems.length > 0;
        auto row = new TRow(item, canExpand, treeLevel, dividerSize);
        
        row.isResizedByParent = false;
        
        assert(rowContainer);
        if (auto scrollBox = cast(ScrollBox) rowContainer)
        {
            assert(scrollBox.contentWidth > 0);
            row.width = scrollBox.contentWidth;
        }
        else
        {
            row.width = rowContainer.width;
        }

        //TODO min height
        if (row.height == 0)
        {
            row.height = 10;
        }

        row.isCreateBottomBorder = false;

        row.onExpandOldNewValue = (oldv, newv) {
            if (rowContainer)
            {
                rowContainer.setInvalid;
            }
        };
        import api.dm.kit.graphics.colors.rgba : RGBA;

        //row.boundsColor = RGBA.blue;
        //row.isDrawBounds = true;

        //row.isResizedWidthByParent = false;

        row.isExpandable = canExpand;
        if (parent)
        {
            parent.childrenRows ~= row;
            row.parentRow = parent;
        }

        root.addCreate(row);
        rows ~= row;
        foreach (ci; 0 .. columnCount)
        {
            row.createColumn;
            row.setItem;
        }

        if(rowIndex == rowLastIndex){
            row.isLastLevel = true;
        }

        row.onSelectedOldNewValue = (oldv, newv) {
            if (row is currentSelected)
            {
                return;
            }
            auto oldSelected = currentSelected ? currentSelected : null;
            currentSelected = row;
            // if (onSelectedOldNewRow)
            // {
            //     onSelectedOldNewRow(oldSelected, currentSelected);
            // }
        };

        if (item.childrenItems.length > 0)
        {
            treeLevel++;
            rowIndex = 0;
            auto lastIndex = item.childrenItems.length - 1;
            foreach (ch; item.childrenItems)
            {
                buildTree(root, ch, row, treeLevel, rowIndex, lastIndex);
                rowIndex++;
            }
        }
    }

    // TRow findLastRowUnsafe(size_t treeLevel = 0){
    //    size_t maxLe
    //     auto lastBranchRow = rows[$ - 1];
    //     foreach(auto ch; lastBranchRow.childrenRows){

    //     }
    // }
}
