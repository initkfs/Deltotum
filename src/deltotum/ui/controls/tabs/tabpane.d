module deltotum.ui.controls.tabs.tabpane;

import deltotum.ui.containers.container : Container;
import deltotum.ui.theme.theme : Theme;
import deltotum.graphics.shape.shape_style : ShapeStyle;
import deltotum.ui.containers.hbox : HBox;
import deltotum.ui.containers.vbox : VBox;
import deltotum.ui.containers.stack_box : StackBox;
import deltotum.ui.controls.tabs.tab : Tab;
import deltotum.ui.controls.button : Button;

class TabButton : Button {
    @property Tab tab;
    @property void delegate(Tab tab) onTab;

    this(Theme theme, Tab tab){
        super(theme, 80, 40, tab.text);
        this.tab = tab;
        onAction = (e){
            if(onTab !is null){
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
        ShapeStyle* headerStyle;
        ShapeStyle* contentStyle;
        Tab[] tabs = [];
        Tab currentTab;
    }

    this(Theme theme, Tab[] tabs)
    {
        super(theme);
        headerStyle = new ShapeStyle(0, theme.colorSecondary, true, theme.colorPrimary);
        contentStyle = new ShapeStyle(0, theme.colorSecondary, true, theme.colorSecondary);
        this.tabs = tabs;
    }

    override void create()
    {
        super.create;

        container = new VBox(theme);
        build(container);

        header = new HBox(theme, 1);
        header.backgroundStyle = headerStyle;
        header.width = width;
        header.height = 40;
        container.addCreated(header);
        header.createBackground;

        foreach (i, Tab tab; tabs)
        {
            //TODO move, remove tabs, etc
            auto tabButton = new TabButton(theme, tab);
            tabButton.tab = tab;
            tabButton.onTab = (tab) {
                changeTab(tab);
            };
            header.addCreated(tabButton);
        }

        header.invalidate;

        content = new StackBox(theme);
        content.backgroundStyle = contentStyle;
        container.addCreated(content);
        content.width = width;
        content.height = height - header.height;
        content.createBackground;

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
