module deltotum.gui.controls.tabs.tabpane;

import deltotum.kit.sprites.sprite : Sprite;
import deltotum.gui.controls.control : Control;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.gui.containers.hbox : HBox;
import deltotum.gui.containers.vbox : VBox;
import deltotum.gui.containers.stack_box : StackBox;
import deltotum.gui.controls.tabs.tab : Tab;
import deltotum.gui.controls.tabs.tab_header : TabHeader;
import deltotum.kit.sprites.layouts.vlayout : VLayout;

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

        StackBox content;
    }

    this(TabHeader header = null)
    {
        this.header = header ? header : new TabHeader;
        this.header.isHGrow = true;

        content = new StackBox;
        content.isBackground = false;
        content.isVGrow = true;
        content.isHGrow = true;

        layout = new VLayout;
    }

    override void initialize(){
        super.initialize;
        
        enablePadding;
    }

    override void create()
    {
        super.create;

        header.width = width;

        addCreate(header);

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
        if (auto tab = cast(Tab) sprite)
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

            currentTab.content.isVisible = true;
            //currentTab.content.isUpdatable = true;
        }
    }

    override void destroy()
    {
        super.destroy;
        if (header)
        {
            header.destroy;
        }

        if (content)
        {
            content.destroy;
        }
    }
}
