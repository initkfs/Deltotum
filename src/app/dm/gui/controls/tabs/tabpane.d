module app.dm.gui.controls.tabs.tabpane;

import app.dm.kit.sprites.sprite : Sprite;
import app.dm.gui.controls.control : Control;
import app.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import app.dm.gui.containers.hbox : HBox;
import app.dm.gui.containers.vbox : VBox;
import app.dm.gui.containers.stack_box : StackBox;
import app.dm.gui.containers.container : Container;
import app.dm.gui.controls.tabs.tab : Tab;
import app.dm.gui.controls.tabs.tab_header : TabHeader;
import app.dm.kit.sprites.layouts.vlayout : VLayout;

/**
 * Authors: initkfs
 */
class TabPane : Control
{
    bool isLazyContent = true;

    private
    {
        TabHeader header;
        Tab currentTab;

        Container content;
    }

    this(TabHeader header = null)
    {
        super();
        id = "tab_pane";
        this.header = header ? header : new TabHeader;
        this.header.isHGrow = true;

        content = new Container;
        content.isBackground = false;
        content.isVGrow = true;
        content.isHGrow = true;

        layout = new VLayout;
        layout.isAlignX = false;
    }

    override void initialize()
    {
        super.initialize;

        enablePadding;
    }

    override void create()
    {
        super.create;

        header.width = width;

        addCreate(header);

        import app.dm.gui.controls.separators.hseparator : HSeparator;

        auto sep = new HSeparator;
        sep.id = "tab_pane_header_separator";
        addCreate(sep);

        addCreate(content);

        if (header.tabs.length > 0)
        {
            changeTab(header.tabs[0]);
        }
    }

    override void addCreate(Sprite[] sprite)
    {
        foreach (s; sprite)
        {
            addCreate(s);
        }
    }

    override void addCreate(Sprite sprite, long index = -1)
    {
        import app.core.utils.types : castSafe;

        if (auto tab = sprite.castSafe!Tab)
        {
            createTabContent(tab);
            return;
        }

        super.addCreate(sprite, index);
    }

    protected void createTabContent(Tab tab)
    {
        tab.onAction = () { changeTab(tab); };
        header.addCreate(tab);

        if (tab.content)
        {
            tab.content.isVisible = false;
            //tab.content.isUpdatable = false;
        }
    }

    //TODO events
    void changeTab(Tab newTab)
    {
        if (newTab is currentTab)
        {
            return;
        }

        if (currentTab)
        {
            if (currentTab.content)
            {
                currentTab.content.isVisible = false;
                //currentTab.content.isUpdatable = false;
            }

            currentTab.isSelected = false;
        }

        currentTab = newTab;
        currentTab.isSelected = true;

        if (currentTab.content)
        {
            if (!currentTab.content.isCreated)
            {
                content.addCreate(newTab.content);
            }
            else
            {
                //TODO add?
                if (!content.hasDirect(newTab.content))
                {
                    content.add(newTab.content);
                }
            }

            currentTab.content.isVisible = true;
            //currentTab.content.isUpdatable = true;
        }
    }

    override void dispose()
    {
        super.dispose;
        if (header && !header.isDisposed)
        {
            header.dispose;
        }

        if (content && !content.isDisposed)
        {
            content.dispose;
        }
    }
}
