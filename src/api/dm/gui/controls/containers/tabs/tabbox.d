module api.dm.gui.controls.containers.tabs.tabbox;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.containers.tabs.tab : Tab;
import api.dm.gui.controls.containers.tabs.tab_header : TabHeader;
import api.dm.gui.controls.separators.base_separator : BaseSeparator;

/**
 * Authors: initkfs
 */
class TabBox : Container
{
    bool isLazyContent = true;

    TabHeader header;
    bool isCreateHeader = true;
    TabHeader delegate(TabHeader) onNewHeader;
    void delegate(TabHeader) onCreatedHeader;

    BaseSeparator separator;
    bool isCreateSeparator = true;
    BaseSeparator delegate(BaseSeparator) onNewSeparator;
    void delegate(BaseSeparator) onCreatedSeparator;

    Container contentContainer;
    bool isCreateContentContainer = true;
    Container delegate(Container) onNewContentContainer;
    void delegate(Container) onCreatedContentContainer;

    protected
    {
        Tab _currentTab;
    }

    this()
    {
        id = "tab_box";

        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout(0);
        layout.isAlignX = false;
    }

    override void create()
    {
        super.create;

        if (!header && isCreateHeader)
        {
            auto h = newTabHeader;
            header = !onNewHeader ? h : onNewHeader(h);

            header.width = width;
            if (header.width == 0)
            {
                header.width = 1;
            }
            header.isHGrow = true;

            addCreate(header);
            if (onCreatedHeader)
            {
                onCreatedHeader(header);
            }
        }

        if (!separator && isCreateSeparator)
        {
            auto sep = newSeparator;
            separator = !onNewSeparator ? sep : onNewSeparator(sep);
            addCreate(separator);
            if (onCreatedSeparator)
            {
                onCreatedSeparator(separator);
            }
        }

        if (!contentContainer && isCreateContentContainer)
        {
            auto c = newContentContainer;
            contentContainer = !onNewContentContainer ? c : onNewContentContainer(c);

            contentContainer.isVGrow = true;
            contentContainer.isHGrow = true;

            addCreate(contentContainer);
            if (onCreatedContentContainer)
            {
                onCreatedContentContainer(contentContainer);
            }
        }

        if (header.tabs.length > 0)
        {
            changeTab(header.tabs[0]);
        }
    }

    bool has(Tab tab)
    {
        if (!header)
        {
            return false;
        }
        foreach (t; header.tabs)
        {
            if (tab is t)
            {
                return true;
            }
        }
        return false;
    }

    //TODO events
    bool changeTab(Tab newTab)
    {
        if (!has(newTab) || newTab is _currentTab)
        {
            return false;
        }

        if (_currentTab)
        {
            if (_currentTab.content)
            {
                _currentTab.content.isVisible = false;
            }

            _currentTab.isSelected = false;
        }

        _currentTab = newTab;
        _currentTab.isSelected = true;

        if (_currentTab.content)
        {
            if (!contentContainer.hasDirect(_currentTab.content))
            {
                if (!_currentTab.content.isCreated)
                {
                    contentContainer.addCreate(newTab.content);
                }
                else
                {
                    contentContainer.add(newTab.content);
                }
            }

            _currentTab.content.isVisible = true;
        }

        return true;
    }

    alias add = Container.add;

    override void add(Sprite2d obj, long index = -1)
    {
        if (auto tab = cast(Tab) obj)
        {
            createTabContent(tab);
            return;
        }

        super.add(obj, index);
    }

    protected void createTabContent(Tab tab)
    {
        tab.onAction = () {

            if(_currentTab is tab){
                return;
            }

            if (!changeTab(tab))
            {
                logger.errorf("Failed to change old tab '%s' to new tab '%s'", _currentTab, tab
                        .toString);
            }
        };

        header.addCreate(tab);

        if (tab.content)
        {
            tab.content.isVisible = false;
        }
    }

    TabHeader newTabHeader(double tabSpacing = 1) => new TabHeader(tabSpacing);
    BaseSeparator newSeparator()
    {
        import api.dm.gui.controls.separators.hseparator : HSeparator;

        return new HSeparator;
    }

    Container newContentContainer()
    {
        import api.dm.gui.controls.containers.stack_box : StackBox;

        auto container = new Container;

        import api.dm.kit.sprites2d.layouts.managed_layout : ManagedLayout;

        container.layout = new ManagedLayout;
        container.layout.isAutoResize = true;
        return container;
    }

}
