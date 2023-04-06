module deltotum.ui.controls.tabs.tabpane;

import deltotum.ui.containers.container : Container;
import deltotum.toolkit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.ui.containers.hbox : HBox;
import deltotum.ui.containers.vbox : VBox;
import deltotum.ui.containers.stack_box : StackBox;
import deltotum.ui.controls.tabs.tab : Tab;
import deltotum.ui.controls.buttons.button : Button;

class TabButton : Button
{
    Tab tab;
    void delegate(Tab tab) onTab;

    this(Tab tab)
    {
        super(80, 40, tab.text);
        this.tab = tab;
        onAction = (e) {
            if (onTab !is null)
            {
                onTab(tab);
            }
        };
    }
}

/**
 * Authors: initkfs
 */
class TabPane : Container
{

    private
    {
        VBox container;
        HBox header;
        StackBox content;
        GraphicStyle headerStyle;
        GraphicStyle contentStyle;
        Tab[] tabs;
        Tab currentTab;
    }

    this(Tab[] tabs)
    {
        super();
        this.tabs = tabs;
    }

    override void create()
    {
        super.create;

        headerStyle = GraphicStyle(0, graphics.theme.colorSecondary, true, graphics.theme.colorPrimary);
        contentStyle = GraphicStyle(0, graphics.theme.colorSecondary, true, graphics.theme.colorSecondary);

        container = new VBox();
        build(container);

        header = new HBox(1);
        header.style = headerStyle;
        header.width = width;
        header.height = 40;
        container.addCreated(header);
        //header.createBackground(width, height);

        foreach (i, Tab tab; tabs)
        {
            //TODO move, remove tabs, etc
            auto tabButton = new TabButton(tab);
            tabButton.tab = tab;
            tabButton.onTab = (tab) { changeTab(tab); };
            header.addCreated(tabButton);
        }

        //header.setInvalid;

        content = new StackBox();
        content.style = contentStyle;
        container.addCreated(content);
        content.width = width;
        content.height = height - header.height;
        //content.createBackground(width, height);

        foreach (Tab tab; tabs)
        {
            content.addCreated(tab);
        }

        if (tabs.length > 0)
        {
            changeTab(tabs[0]);
        }

        container.create;
        add(container);
    }

    //TODO events
    void changeTab(Tab newTab)
    {
        if (!newTab.isVisible)
        {
            newTab.isVisible = true;
            //newTab.invalidate;
        }

        currentTab = newTab;

        foreach (Tab tab; tabs)
        {
            if (tab !is currentTab && tab.isVisible)
            {
                tab.isVisible = false;
                //tab.invalidate;
            }

        }
        //content.invalidate;
    }

    override void destroy()
    {
        super.destroy;
        if (header !is null)
        {
            header.destroy;
        }
    }
}
