module api.dm.gui.controls.containers.tabs.tabpane;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.gui.controls.containers.vbox : VBox;
import api.dm.gui.controls.containers.stack_box : StackBox;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.containers.tabs.tab : Tab;
import api.dm.gui.controls.containers.tabs.tab_header : TabHeader;
import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

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

        import api.dm.gui.controls.separators.hseparator : HSeparator;

        auto sep = new HSeparator;
        sep.id = "tab_pane_header_separator";
        addCreate(sep);

        addCreate(content);

        if (header.tabs.length > 0)
        {
            changeTab(header.tabs[0]);
        }
    }

    override void addCreate(Sprite2d[] sprite)
    {
        foreach (s; sprite)
        {
            if(auto control = cast(Control) s){
                addCreate(control);
                continue;;
            }

            addCreate(s);
        }
    }

    override void addCreate(Control control, long index = -1)
    {
        if (auto tab = cast(Tab) control)
        {
            createTabContent(tab);
            return;
        }

        super.addCreate(control, index);
    }

    override void addCreate(Sprite2d sprite, long index = -1)
    {
        import api.core.utils.types : castSafe;

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
