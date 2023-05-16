module deltotum.gui.controls.tabs.tabpane;

import deltotum.kit.sprites.sprite : Sprite;
import deltotum.gui.containers.container : Container;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.gui.containers.hbox : HBox;
import deltotum.gui.containers.vbox : VBox;
import deltotum.gui.containers.stack_box : StackBox;
import deltotum.gui.controls.tabs.tab : Tab;
import deltotum.gui.controls.tabs.tab_header : TabHeader;
import deltotum.kit.sprites.layouts.vertical_layout : VerticalLayout;

/**
 * Authors: initkfs
 */
class TabPane : Container
{

    private
    {
        TabHeader header;
        Tab currentTab;
    }

    StackBox content;

    this(TabHeader header = null)
    {
        this.header = header ? header : new TabHeader;
        content = new StackBox;
        content.isBackground = false;
        layout = new VerticalLayout(2);
    }

    override void initialize()
    {
        super.initialize;
    }

    override void create()
    {
        super.create;

        header.width = width;
        //TODO max button height
        header.height = 50;

        addCreate(header);

        content.width = width;
        content.height = height - header.height;

        addCreate(content);

        if (header.tabs.length > 0)
        {
            changeTab(header.tabs[0]);
        }
    }

    void createTabContent(Tab tab, Sprite obj)
    {
        if (!tab.isBuilt)
        {
            tab.onAction = () { changeTab(tab); };

            header.addCreate(tab);
        }

        //TODO map?
        obj.width = this.content.width;
        obj.height = this.content.height;

        tab.content = obj;
        content.addCreate(obj);

        obj.isVisible = false;
        obj.isUpdatable = false;
    }

    //TODO events
    void changeTab(Tab newTab)
    {
        if (newTab is currentTab)
        {
            return;
        }

        if (currentTab && currentTab.content)
        {
            currentTab.content.isVisible = false;
            currentTab.content.isUpdatable = false;
        }

        if (newTab.content)
        {
            newTab.content.isVisible = true;
            newTab.content.isUpdatable = true;
        }

        currentTab = newTab;
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
