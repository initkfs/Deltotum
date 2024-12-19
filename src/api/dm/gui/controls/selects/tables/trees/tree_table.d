module api.dm.gui.controls.selects.tables.trees.tree_table;

import api.dm.gui.controls.control : Control;
import api.dm.gui.containers.container : Container;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.math.geom2.rect2 : Rect2d;
import api.dm.gui.controls.texts.text : Text;

import api.dm.gui.controls.selects.tables.trees.tree_item : TreeItem;
import api.dm.gui.controls.selects.tables.trees.tree_row : TreeRow;

import api.dm.gui.controls.meters.scrolls.vscroll : VScroll;

import api.math.insets : Insets;
import Math = api.math;

import std.container.dlist : DList;

/**
 * Authors: initkfs
 */
class TreeTable(T) : Control
{
    TreeRow!T[] rows;

    protected
    {
        size_t startVisibleRowIndex;
        size_t endVisibleRowIndex;

        DList!(TreeRow!T) visibleRows;
        size_t visibleRowsLength;
    }

    TreeRow!T currentSelected;

    double maxRowHeight = 0;

    void delegate(TreeRow!T, TreeRow!T) onSelectedOldNewRow;

    Container rowContainer;

    bool isCreateRowContainer = true;
    Container delegate(Container) onNewRowContainer;
    void delegate(Container) onCreatedRowContainer;

    VScroll vScroll;

    this()
    {
        import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

        layout = new HLayout;
        layout.isAutoResize = true;
    }

    override void initialize()
    {
        super.initialize;
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadTreeViewTheme;
    }

    void loadTreeViewTheme()
    {
        if (width == 0)
        {
            initWidth = theme.controlDefaultWidth * 2;
        }

        if (height == 0)
        {
            initHeight = theme.controlDefaultHeight * 4;
        }

        if (maxRowHeight == 0)
        {
            maxRowHeight = theme.controlDefaultHeight / 2;
        }
    }

    override void create()
    {
        super.create;

        if (!rowContainer && isCreateRowContainer)
        {
            auto nc = newRowContainer;
            rowContainer = !onNewRowContainer ? nc : onNewRowContainer(nc);

            rowContainer.isDrawBounds = true;

            import api.dm.kit.graphics.colors.rgba : RGBA;

            rowContainer.boundsColor = RGBA.yellow;

            import api.math.geom2.rect2 : Rect2d;

            auto clip = Rect2d(0, 0, width, height);
            rowContainer.clip = clip;
            rowContainer.isMoveClip = true;
            rowContainer.isResizeClip = true;
            rowContainer.resize(width, height);

            addCreate(rowContainer);
            if (onCreatedRowContainer)
            {
                onCreatedRowContainer(rowContainer);
            }
        }

        vScroll = new VScroll;
        vScroll.isVGrow = true;
        addCreate(vScroll);
        vScroll.isVisible = true;

        double lastScrollValue = vScroll.value;

        vScroll.onValue ~= (v) {
            auto dt = v - lastScrollValue;

            if (rows.length == 0 || dt == 0 || !rowContainer)
            {
                return;
            }

            auto rowRelViewport = rowRelativeViewport;
            auto rowOffsetH = rowRelViewport.height * dt;

            auto endIndex = rows.length - 1;

            //scroll down
            if (dt > 0)
            {
                if (endVisibleRowIndex == endIndex)
                {
                    auto lastRow = visibleRows.back;
                    if (lastRow.boundsRect.bottom <= rowContainer.boundsRect.bottom)
                    {
                        return;
                    }
                }

                auto firstRow = visibleRows.front;
                auto newRowY = firstRow.y - rowOffsetH;
                if ((newRowY + maxRowHeight) <= rowContainer.y)
                {
                    //TODO overflow
                    auto newEndIndex = endVisibleRowIndex + 1;
                    if (newEndIndex >= rows.length)
                    {
                        return;
                    }

                    startVisibleRowIndex++;
                    endVisibleRowIndex = newEndIndex;

                    firstRow.isVisible = false;
                    visibleRows.removeFront;

                    auto lastRow = visibleRows.back;
                    auto newLastY = lastRow.boundsRect.bottom;

                    auto newRow = rows[endVisibleRowIndex];
                    newRow.isVisible = true;

                    newRow.y = newLastY;
                    visibleRows.insertBack(newRow);
                }

                moveVisibleRowsY(-rowOffsetH);
            }
            else
            {
                if (startVisibleRowIndex == 0)
                {
                    auto firstRow = visibleRows.front;
                    if (firstRow.y >= rowContainer.y)
                    {
                        return;
                    }
                }

                auto lastRow = visibleRows.back;
                auto newRowY = lastRow.y + rowOffsetH;
                if (newRowY >= rowContainer.boundsRect.bottom)
                {
                    if (startVisibleRowIndex > 0)
                    {
                        startVisibleRowIndex--;
                        endVisibleRowIndex--;

                        lastRow.isVisible = false;
                        visibleRows.removeBack;

                        auto firstRow = visibleRows.front;

                        auto newRow = rows[startVisibleRowIndex];
                        newRow.isVisible = true;

                        newRow.y = firstRow.y - maxRowHeight;
                        visibleRows.insertFront(newRow);
                    }
                }

                moveVisibleRowsY(-rowOffsetH);
            }

            lastScrollValue = v;
        };

        if (rowContainer)
        {
            rowContainer.resize(width - vScroll.width, height);
        }

        onPointerWheel ~= (ref e) {
            if (vScroll)
            {
                vScroll.fireEvent(e);
                e.isConsumed = true;
            }
        };

    }

    protected void moveVisibleRowsY(double dy)
    {
        foreach (vrow; visibleRows)
        {
            vrow.y = vrow.y + dy;
        }
    }

    Rect2d rowRelativeViewport()
    {
        auto needRows = needViewportRows;
        if (needRows >= rows.length)
        {
            return Rect2d(0, 0, width, 0);
        }
        auto fullHeight = (rows.length - needRows) * maxRowHeight;
        return Rect2d(0, 0, width, fullHeight);
    }

    Container newRowContainer()
    {
        return new Container;
    }

    override void applyLayout()
    {
        super.applyLayout;
    }

    size_t needViewportRows()
    {
        assert(rowContainer);
        assert(maxRowHeight > 0);
        size_t fullRows = cast(size_t) Math.round(rowContainer.height / maxRowHeight);
        return fullRows;
    }

    size_t needVisibleRows()
    {
        size_t fullRows = needViewportRows;
        //+1 last row
        fullRows++;
        return fullRows;
    }

    void createVisibleRows()
    {
        visibleRows.clear;
        visibleRowsLength = 0;
        foreach (row; rows)
        {
            row.isVisible = false;
        }

        size_t fullRows = needVisibleRows;
        auto targetRows = Math.min(fullRows, rows.length);
        assert(targetRows > 0);
        foreach (ri; 0 .. targetRows)
        {
            auto row = rows[ri];
            row.isVisible = true;
            visibleRows.insertBack(row);
            visibleRowsLength++;
        }

        startVisibleRowIndex = 0;
        endVisibleRowIndex = visibleRowsLength - 1;

        alignVisibleRows;
    }

    void alignVisibleRows()
    {
        assert(rowContainer);
        auto nextY = rowContainer.y;
        foreach (vrow; visibleRows[])
        {
            vrow.y = nextY;
            nextY += maxRowHeight;
        }
    }

    protected void buildTree(
        Sprite2d root,
        TreeItem!T item,
        TreeRow!T parent = null,
        size_t treeLevel = 0)
    {
        const canExpand = item.childrenItems.length > 0;

        auto row = new TreeRow!T(item, canExpand, treeLevel);

        row.onExpandOldNewValue = (oldv, newv){
            auto sumHeight = maxRowHeight;
            sumHeight += row.countExpandChildren * maxRowHeight;
        };

        import api.dm.kit.graphics.colors.rgba : RGBA;

        row.boundsColor = RGBA.blue;
        row.isDrawBounds = true;
        row.isVisible = false;

        row.height = maxRowHeight;
        row.maxHeight = maxRowHeight;

        if (rowContainer)
        {
            row.width = rowContainer.width;
        }

        row.isExpandable = canExpand;
        if (parent)
        {
            parent.childrenRows ~= row;
            row.parentRow = parent;
        }

        root.addCreate(row);
        rows ~= row;

        row.padding = Insets(0);

        row.onSelectedOldNewValue = (oldv, newv) {
            if (row is currentSelected)
            {
                return;
            }
            auto oldSelected = currentSelected ? currentSelected : null;
            currentSelected = row;
            if (onSelectedOldNewRow)
            {
                onSelectedOldNewRow(oldSelected, currentSelected);
            }
        };

        if (item.childrenItems.length > 0)
        {
            treeLevel++;
            foreach (ch; item.childrenItems)
            {
                buildTree(root, ch, row, treeLevel);
            }
        }
    }

    bool clear()
    {
        if (rows.length == 0)
        {
            return false;
        }

        rows = [];
        if (rowContainer)
        {
            rowContainer.removeAll;
        }

        return true;
    }

    private void verifyRows()
    {
        if (rows.length > 0)
        {
            auto lastRow = rows[$ - 1];
            lastRow.setLastRowLabel;
        }
    }

    void fill(T[] items)
    {
        TreeItem!T[] treeItems;
        foreach (item; items)
        {
            treeItems ~= new TreeItem!T(item);
        }
        fill(treeItems);
    }

    void fill(TreeItem!T[] items)
    {
        clear;

        assert(rowContainer);

        foreach (item; items)
        {
            buildTree(rowContainer, item);
        }
        verifyRows;
        createVisibleRows;
    }

    void fill(TreeItem!T item)
    {
        TreeItem!T[1] items = [item];
        fill(items);
    }
}
