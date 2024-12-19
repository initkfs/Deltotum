module api.dm.gui.controls.selects.tables.virtuals.virtual_table;

import api.dm.gui.controls.control : Control;
import api.dm.gui.containers.container : Container;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.math.geom2.rect2 : Rect2d;
import api.dm.gui.controls.texts.text : Text;

import api.dm.gui.controls.selects.tables.base_table_row : BaseTableRow;
import api.dm.gui.controls.selects.tables.base_table_item : BaseTableItem;
import api.dm.gui.controls.selects.tables.virtuals.virtual_row : VirtualRow;
import api.dm.gui.controls.selects.tables.base_table: BaseTable;

import api.dm.gui.controls.meters.scrolls.vscroll : VScroll;

import api.math.insets : Insets;
import Math = api.math;

import std.container.dlist : DList;

/**
 * Authors: initkfs
 */
class VirtualTable(T, TR : VirtualRow!T) : BaseTable
{
    protected
    {
        size_t startVisibleRowIndex;
        size_t endVisibleRowIndex;

        DList!TR visibleRows;
        size_t visibleRowsLength;
    }

    T[] items;

    double maxRowHeight = 0;

    VScroll vScroll;

    override void initialize()
    {
        super.initialize;
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadVirtualTableTheme;
    }

    void loadVirtualTableTheme()
    {
        if (maxRowHeight == 0)
        {
            maxRowHeight = theme.controlDefaultHeight / 2;
        }
    }

    override void create()
    {
        super.create;

        tryCreateRowContainer;

        assert(rowContainer);

        vScroll = new VScroll;
        vScroll.isVGrow = true;
        addCreate(vScroll);
        vScroll.isVisible = true;

        double lastScrollValue = vScroll.value;

        vScroll.onValue ~= (v) {
            auto dt = v - lastScrollValue;

            if (items.length == 0 || dt == 0 || !rowContainer)
            {
                return;
            }

            auto rowRelViewport = rowRelativeViewport;
            auto rowOffsetH = rowRelViewport.height * dt;

            auto endIndex = items.length - 1;

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
                    if (newEndIndex >= items.length)
                    {
                        return;
                    }

                    startVisibleRowIndex++;
                    endVisibleRowIndex = newEndIndex;

                    visibleRows.removeFront;

                    auto lastRow = visibleRows.back;
                    auto newLastY = lastRow.boundsRect.bottom;

                    auto newRowItem = items[endVisibleRowIndex];
                    firstRow.rowItem = newRowItem;

                    firstRow.y = newLastY;
                    visibleRows.insertBack(firstRow);
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

                        visibleRows.removeBack;

                        auto firstRow = visibleRows.front;

                        auto newRowItem = items[startVisibleRowIndex];
                        lastRow.rowItem = newRowItem;

                        lastRow.y = firstRow.y - maxRowHeight;
                        visibleRows.insertFront(lastRow);
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
        if (needRows >= items.length)
        {
            return Rect2d(0, 0, width, 0);
        }
        auto fullHeight = (items.length - needRows) * maxRowHeight;
        return Rect2d(0, 0, width, fullHeight);
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
        size_t fullRows = needVisibleRows;
        if(fullRows > visibleRowsLength){
            fullRows = fullRows - visibleRowsLength;
        }

        foreach (vrow; visibleRows)
        {
            vrow.isVisible = false;
            vrow.isEmpty = true;
        }

        assert(rowContainer);

        visibleRowsLength = 0;

        foreach (ri; 0 .. fullRows)
        {
            auto row = newRow;
            rowContainer.addCreate(row);

            auto item = items[ri];
            row.rowItem = item;

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

    protected TR newRow()
    {
        auto row = new TR;

        import api.dm.kit.graphics.colors.rgba: RGBA;

        row.boundsColor = RGBA.blue;
        row.isDrawBounds = true;
        row.isVisible = false;

        row.height = maxRowHeight;
        row.maxHeight = maxRowHeight;

        if (rowContainer)
        {
            row.width = rowContainer.width;
        }
        return row;
    }


    void fill(T[] items)
    {
        clear;

        this.items = items;
        
        createVisibleRows;
    }
}
