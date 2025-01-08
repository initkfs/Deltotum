module api.dm.gui.controls.selects.tables.clipped.trees.tree_row;

import api.dm.gui.controls.selects.tables.base_table_row : BaseTableRow;
import api.dm.gui.controls.selects.tables.base_table_column : BaseTableColumn;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.texts.text : Text;

import api.dm.gui.controls.selects.tables.clipped.trees.tree_item : TreeItem;
import api.math.geom2.vec2 : Vec2d;

class TreeRowLevelGraphics : Control
{
    size_t level;
    bool isLastLevelRow;
    bool isLastRow;

    double graphicsGap = 0;

    this()
    {
        //isDrawBounds = true;
    }

    override void initialize()
    {
        super.initialize;

        if (width == 0)
        {
            assert(graphicsGap > 0);
            initWidth = level > 0 ? ((level + 1) * graphicsGap) : (graphicsGap * 2);
        }
    }

    override void loadTheme()
    {
        super.loadTheme;

        if (graphicsGap == 0)
        {
            graphicsGap = theme.controlGraphicsGap * 2;
        }
    }

    override void drawContent()
    {
        super.drawContent;

        const b = boundsRect;

        graphics.changeColor(theme.colorAccent);
        scope (exit)
        {
            graphics.restoreColor;
        }

        double nextX = b.x + graphicsGap;
        if (level == 0)
        {
            if (!isLastLevelRow)
            {
                graphics.line(Vec2d(nextX, b.y), Vec2d(nextX, b.bottom));
                graphics.line(Vec2d(nextX, b.middleY), Vec2d(nextX + graphicsGap, b.middleY));
            }
        }
        else
        {
            auto lastLevel = level - 1;
            //TODO paddings
            foreach (l; 0 .. level)
            {
                if (l == lastLevel)
                {
                    if (!isLastLevelRow)
                    {
                        graphics.line(Vec2d(nextX, b.y), Vec2d(nextX, b.bottom));
                        graphics.line(Vec2d(nextX, b.middleY), Vec2d(nextX + graphicsGap, b.middleY));
                    }
                    else
                    {
                        break;
                    }
                }
                else
                {
                    if (!isLastLevelRow)
                    {
                        graphics.line(Vec2d(nextX, b.y), Vec2d(nextX, b.bottom));
                    }
                    else
                    {
                        // if (level > 0 && !isLastRow)
                        // {
                        //     graphics.line(Vec2d(nextX, b.y), Vec2d(nextX, b.bottom));
                        // }
                        // else
                        // {
                            graphics.line(Vec2d(nextX, b.y), Vec2d(nextX, b.middleY));
                        //}
                        graphics.line(Vec2d(nextX, b.middleY), Vec2d(b.right, b
                                .middleY));
                    }
                }

                nextX += graphicsGap * 1.5;
            }
        }

        if (isLastLevelRow)
        {
            // if (level > 0 && !isLastRow)
            // {
            //     graphics.line(Vec2d(nextX, b.y), Vec2d(nextX, b.bottom));
            // }
            // else
            // {
                graphics.line(Vec2d(nextX, b.y), Vec2d(nextX, b.middleY));
            //}
            graphics.line(Vec2d(nextX, b.middleY), Vec2d(nextX + graphicsGap, b
                    .middleY));
            return;
        }
    }
}

/**
 * Authors: initkfs
 */
class TreeRow(T) : BaseTableRow!(T, BaseTableColumn!T)
{
    TreeItem!T rowItem;

    TreeRow!T parentRow;
    TreeRow!T[] childrenRows;

    void delegate(bool oldValue, bool newValue) onSelectedOldNewValue;
    void delegate(bool oldValue, bool newValue) onExpandOldNewValue;

    size_t treeLevel;

    protected
    {
        bool isExpand;
    }

    import GuiSymbols = api.dm.gui.gui_text_symbols;

    dstring expandSymbol;
    dstring hidingSymbol;

    bool isExpandable = true;

    dstring delegate(T) itemTextProvider;

    TreeRowLevelGraphics levelGraphics;
    bool isCreateLevelGraphics = true;
    TreeRowLevelGraphics delegate(TreeRowLevelGraphics) onNewLevelGraphics;
    void delegate(TreeRowLevelGraphics) onCreatedLevelGraphics;

    Text expandGraphics;
    bool isCreateExpandGraphics = true;
    Text delegate(Text) onNewExpandGraphics;
    void delegate(Text) onCreatedExpandGraphics;

    this(TreeItem!T rowItem, bool isExpand = false, size_t treeLevel = 0, double dividerSize = 0)
    {
        super(dividerSize);

        import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

        layout = new HLayout;
        layout.isAutoResize = true;

        if (isExpand)
        {
            isCreateActionEffect = false;
            isCreateActionEffectAnimation = false;
        }

        this.rowItem = rowItem;
        this.treeLevel = treeLevel;
        this.isExpand = isExpand;
    }

    override void initialize()
    {
        super.initialize;
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
        import api.dm.gui.controls.texts.text : Text;
        import api.math.insets : Insets;

        if (treeLevel > 0 && !levelGraphics && isCreateLevelGraphics)
        {
            auto nlg = newLevelGraphics;
            levelGraphics = !onNewLevelGraphics ? nlg : onNewLevelGraphics(nlg);

            levelGraphics.height = height;
            levelGraphics.level = treeLevel;
            levelGraphics.isVGrow = true;

            addCreate(levelGraphics);
            if (onCreatedLevelGraphics)
            {
                onCreatedLevelGraphics(levelGraphics);
            }
        }

        //TODO child !is null
        if (rowItem.childrenItems.length > 0 && !expandGraphics && isCreateExpandGraphics)
        {
            auto eg = newExpandGraphics;
            expandGraphics = !onNewExpandGraphics ? eg : onNewExpandGraphics(eg);

            expandGraphics.padding = Insets(0);
            expandGraphics.text = isExpand ? expandSymbol : hidingSymbol;

            addCreate(expandGraphics);
            if (onCreatedExpandGraphics)
            {
                onCreatedExpandGraphics(expandGraphics);
            }

            //TODO reuse
            onPointerPress ~= (ref e) {
                this.isExpand = !isExpand;
                setExpandGraphics;
                foreach (ch; childrenRows)
                {
                    toggleTreeBranch(ch, isExpand);
                }
            };

            setExpandGraphics;
        }

        super.create;
    }

    void setItem()
    {
        foreach (ci, col; columns)
        {
            col.item = rowItem.data;
        }
    }

    TreeRowLevelGraphics newLevelGraphics()
    {
        return new TreeRowLevelGraphics;
    }

    Text newExpandGraphics()
    {
        return new Text(">");
    }

    Text newItemText(dstring text)
    {
        return new Text(text);
    }

    bool expand() => isExpand;

    void expand(bool value, bool isTriggerListeners = true)
    {
        bool oldValue = isExpand;
        isExpand = value;

        setExpandGraphics;

        isVisible = value;
        isManaged = value;
        isLayoutManaged = value;

        if (isTriggerListeners && onExpandOldNewValue)
        {
            onExpandOldNewValue(oldValue, value);
        }

    }

    size_t countExpandChildren()
    {
        size_t counter;
        foreach (row; childrenRows)
        {
            if (row.expand)
            {
                counter++;
            }
        }
        return counter;
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

    void isLastRow(bool v){
        if(levelGraphics){
            levelGraphics.isLastRow = v;
        }
    }

    bool isLastLevel() => _last;
    void isLastLevel(bool v)
    {
        if (v && !_last)
        {
            setLastRowLabel;
        }
        _last = v;
    }

    protected void setLastRowLabel()
    {
        if (!levelGraphics)
        {
            return;
        }

        levelGraphics.isLastLevelRow = true;
    }
}
