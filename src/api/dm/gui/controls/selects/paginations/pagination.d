module api.dm.gui.controls.selects.paginations.pagination;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.selects.base_selector : BaseSelector;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.switches.buttons.button : Button;
import api.dm.gui.controls.switches.buttons.navigate_button : NavigateButton, NavigateDirection;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.texts.text_view: TextView;

import std.conv : to;

/**
 * Authors: initkfs
 */
class Pagination : BaseSelector!size_t
{
    void delegate(size_t) pageFactory;

    protected
    {
        size_t numPages;
        size_t activePageFirstIndex;
    }

    Control pageContainer;
    bool isCreatePageContainer = true;
    Control delegate(Control) onNewPageContainer;
    void delegate(Control) onConfiguredPageContainer;
    void delegate(Control) onCreatedPageContainer;

    Button prevButton;
    bool isCreatePrevButton = true;
    Button delegate(Button) onNewPrevButton;
    void delegate(Button) onConfiguredPrevButton;
    void delegate(Button) onCreatedPrevButton;

    Button nextButton;
    bool isCreateNextButton = true;
    Button delegate(Button) onNewNextButton;
    void delegate(Button) onConfiguredNextButton;
    void delegate(Button) onCreatedNextButton;

    Button firstButton;
    bool isCreateFirstButton = true;
    Button delegate(Button) onNewFirstButton;
    void delegate(Button) onConfiguredFirstButton;
    void delegate(Button) onCreatedFirstButton;

    Button endButton;
    bool isCreateEndButton = true;
    Button delegate(Button) onNewEndButton;
    void delegate(Button) onConfiguredEndButton;
    void delegate(Button) onCreatedEndButton;

    Button currentButton;
    bool isCreateCurrentButton = true;
    Button delegate(Button) onNewCurrentButton;
    void delegate(Button) onConfiguredCurrentButton;
    void delegate(Button) onCreatedCurrentButton;

    Text[] skipPagesPlaceholders;
    dstring skipPagePlaceholderText = ".";
    bool isCreateSkipPagePlaceholders = true;
    Text delegate(Text) onNewSkipPagePlaceholder;
    void delegate(Text) onConfiguredSkipPagePlaceholder;
    void delegate(Text) onCreatedSkipPagePlaceholder;

    Button[] activePageButtons;
    bool isCreateActivePageButtons = true;
    Button delegate(Button) onNewActivePageButton;
    void delegate(Button) onConfiguredActivePageButton;
    void delegate(Button) onCreatedActivePageButton;

    Container infoContainer;
    bool isCreateInfoContainer = true;
    Container delegate(Container) onNewInfoContainer;
    void delegate(Container) onConfiguredInfoContainer;
    void delegate(Container) onCreatedInfoContainer;

    Text infoPageCurrent;
    bool isCreateInfoPageCurrent = true;
    Text delegate(Text) onNewInfoPageCurrent;
    void delegate(Text) onConfiguredInfoPageCurrent;
    void delegate(Text) onCreatedInfoPageCurrent;

    TextView selectNewPage;
    bool isCreateSelectNewPage = true;
    TextView delegate(TextView) onNewSelectNewPage;
    void delegate(TextView) onConfiguredSelectNewPage;
    void delegate(TextView) onCreatedSelectNewPage;

    size_t activePageCount = 3;

    this(size_t numPages = 10)
    {
        this.numPages = numPages;

        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        this.layout = new VLayout;
        layout.isAlignX = true;
        layout.isAutoResize = true;
    }

    override void create()
    {
        super.create;

        if (!pageContainer && isCreatePageContainer)
        {
            auto container = newPageContainer;
            pageContainer = !onNewPageContainer ? container : onNewPageContainer(container);

            if (onConfiguredPageContainer)
            {
                onConfiguredPageContainer(pageContainer);
            }

            addCreate(pageContainer);

            if (onCreatedPageContainer)
            {
                onCreatedPageContainer(container);
            }
        }

        if (!prevButton && isCreatePrevButton)
        {
            auto pb = newPrevButton;
            prevButton = !onNewPrevButton ? pb : onNewPrevButton(pb);

            prevButton.onAction ~= (ref e) {
                if (current == 0)
                {
                    return;
                }
                auto newIndex = current - 1;
                pageIndex(newIndex);
            };

            if (onConfiguredPrevButton)
            {
                onConfiguredPrevButton(prevButton);
            }

            pageRoot.addCreate(prevButton);

            if (onCreatedPrevButton)
            {
                onCreatedPrevButton(prevButton);
            }
        }

        if (!firstButton && isCreateFirstButton)
        {
            auto fb = newPageButton("1");
            firstButton = !onNewFirstButton ? fb : onNewFirstButton(fb);
            firstButton.id = "first_button";

            firstButton.onAction ~= (ref e) { setFirstPage; };

            if (onConfiguredFirstButton)
            {
                onConfiguredFirstButton(firstButton);
            }

            pageRoot.addCreate(fb);

            if (onCreatedFirstButton)
            {
                onCreatedFirstButton(firstButton);
            }

            createSkipPagePlaceholder(pageRoot);
        }

        if (activePageButtons.length == 0 && isCreateActivePageButtons)
        {
            activePageFirstIndex = 1;

            foreach (_i; 0 .. activePageCount)
                (size_t i) {
                auto newButton = newPageButton((i + activePageFirstIndex + 1).to!dstring);
                auto activePage = !onNewActivePageButton ? newButton : onNewActivePageButton(
                    newButton);

                activePage.onAction ~= (ref e) {
                    auto pi = i + activePageFirstIndex;
                    pageIndex(pi);
                };

                if (onConfiguredActivePageButton)
                {
                    onConfiguredActivePageButton(activePage);
                }

                pageRoot.addCreate(activePage);

                if (onCreatedActivePageButton)
                {
                    onCreatedActivePageButton(activePage);
                }

                //TODO check exists
                activePageButtons ~= activePage;
            }(_i);

            createSkipPagePlaceholder(pageRoot);
        }

        if (!endButton && isCreateEndButton)
        {
            auto newEnd = newPageButton(numPages.to!dstring);
            endButton = !onNewEndButton ? newEnd : onNewEndButton(newEnd);

            endButton.onAction ~= (ref e) { setLastPage; };

            if (onConfiguredEndButton)
            {
                onConfiguredEndButton(endButton);
            }

            pageRoot.addCreate(endButton);

            if (onCreatedEndButton)
            {
                onCreatedEndButton(endButton);
            }
        }

        if (!nextButton && isCreateNextButton)
        {
            auto newNext = newNextButton;
            nextButton = !onNewNextButton ? newNext : onNewNextButton(newNext);

            nextButton.onAction ~= (ref e) {
                auto newIndex = current + 1;
                if (newIndex >= numPages)
                {
                    return;
                }
                pageIndex(newIndex);
            };

            if (onConfiguredNextButton)
            {
                onConfiguredNextButton(nextButton);
            }

            pageRoot.addCreate(nextButton);

            if (onCreatedNextButton)
            {
                onCreatedNextButton(nextButton);
            }
        }

        if (!infoContainer && isCreateInfoContainer)
        {
            auto ic = newInfoContainer;
            infoContainer = !onNewInfoContainer ? ic : onNewInfoContainer(ic);

            if (onConfiguredInfoContainer)
            {
                onConfiguredInfoContainer(infoContainer);
            }

            addCreate(infoContainer);

            if (onCreatedInfoContainer)
            {
                onCreatedInfoContainer(infoContainer);
            }
        }

        auto infoRoot = infoContainer ? infoContainer : this;

        if (!selectNewPage && isCreateSelectNewPage)
        {
            auto newSelect = newSelectNewPage;
            selectNewPage = !onNewSelectNewPage ? newSelect : onNewSelectNewPage(newSelect);

            selectNewPage.isEditable = true;
            //selectNewPage.isBorder = true;

            selectNewPage.onKeyPress ~= (ref e) {
                import api.dm.com.inputs.com_keyboard : ComKeyName;

                if (e.keyName == ComKeyName.key_return)
                {
                    auto newPage = selectNewPage.text.to!size_t;
                    if (newPage == 0 && newPage >= numPages)
                    {
                        return;
                    }

                    auto newPageIndex = newPage - 1;

                    if (newPageIndex == 0)
                    {
                        setFirstPage;
                    }
                    else if (newPageIndex == numPages - 1)
                    {
                        setLastPage;
                    }
                    else
                    {
                        size_t pageCount = newPageIndex / activePageCount;
                        auto pageFirstIndex = 1 + (pageCount) * activePageButtons.length;
                        activePageFirstIndex = pageFirstIndex;
                        updateActiveButtons;
                        pageIndex(newPageIndex);
                    }

                }
            };

            if (onConfiguredSelectNewPage)
            {
                onConfiguredSelectNewPage(selectNewPage);
            }

            infoRoot.addCreate(selectNewPage);

            if (onCreatedSelectNewPage)
            {
                onCreatedSelectNewPage(selectNewPage);
            }
        }

        if (!infoPageCurrent && isCreateInfoPageCurrent)
        {
            auto infoCurrent = newInfoPageCurrent;
            infoPageCurrent = !onNewInfoPageCurrent ? infoCurrent : onNewInfoPageCurrent(
                infoCurrent);

            if (onConfiguredInfoPageCurrent)
            {
                onConfiguredInfoPageCurrent(infoPageCurrent);
            }

            infoRoot.addCreate(infoPageCurrent);

            if (onCreatedInfoPageCurrent)
            {
                onCreatedInfoPageCurrent(infoPageCurrent);
            }
        }

        pageIndex(0, isAllowReplace:
            true, isTriggerListeners:
            false);

        if (infoPageCurrent)
        {
            import std.format : format;

            infoPageCurrent.text = format("/%s", numPages);
        }
    }

    void createSkipPagePlaceholder(Sprite2d root)
    {
        if (!isCreateSkipPagePlaceholders)
        {
            return;
        }

        auto pl = newSkipPagePlaceholder;
        auto placeholder = !onNewSkipPagePlaceholder ? pl : onNewSkipPagePlaceholder(pl);

        if (onConfiguredSkipPagePlaceholder)
        {
            onConfiguredSkipPagePlaceholder(placeholder);
        }

        root.addCreate(placeholder);

        if (onCreatedSkipPagePlaceholder)
        {
            onCreatedSkipPagePlaceholder(placeholder);
        }
    }

    protected Sprite2d pageRoot() => pageContainer ? pageContainer : this;

    Control newPageContainer()
    {
        auto container = new Container;

        import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

        container.layout = new HLayout;
        container.layout.isAutoResize = true;
        container.layout.isAlignY = true;

        return container;
    }

    Container newInfoContainer()
    {
        import api.dm.gui.controls.containers.hbox : HBox;

        auto infoContainer = new HBox;
        infoContainer.isAlignY = true;
        return infoContainer;
    }

    Text newSkipPagePlaceholder() => new Text(skipPagePlaceholderText);
    Text newInfoPageCurrent() => new Text;
    TextView newSelectNewPage() => new TextView("0");
    Button newPrevButton() => NavigateButton.newHPrevButton;
    Button newNextButton() => NavigateButton.newHNextButton;

    protected Button newPageButton(dstring text)
    {
        auto btn = new Button(text);
        btn.width = theme.buttonWidth / 3;
        btn.height = btn.width;
        btn.isFixedButton = true;
        btn.isAutolockButton = true;
        return btn;
    }

    protected void setFirstPage()
    {
        if (pageIndex(0))
        {
            activePageFirstIndex = 1;
            updateActiveButtons;
        }
    }

    void setLastPage()
    {
        auto newIndex = numPages - 1;
        auto pagesCount = numPages / activePageButtons.length;
        auto lastPageIndex = 1 + (pagesCount - 1) * activePageButtons.length;
        // auto newIndexOffset = pagesCount * activePageButtons.length;
        if (pageIndex(newIndex))
        {
            activePageFirstIndex = lastPageIndex;
            updateActiveButtons;
        }
    }

    bool pageIndex(size_t index, bool isAllowReplace = false, bool isTriggerListeners = true)
    {
        if (numPages == 0 || index >= numPages)
        {
            return false;
        }

        if (index == current && !isAllowReplace)
        {
            return false;
        }

        currentForce(index, isTriggerListeners);

        if (selectNewPage)
        {
            selectNewPage.text = (current + 1).to!dstring;
        }

        if (current == 0)
        {
            if (firstButton)
            {
                firstButton.isOn = true;
            }

            resetSelectedPages;
            if (endButton)
            {
                endButton.isOn = false;
            }
        }
        else if (current == numPages - 1)
        {
            if (endButton)
            {
                endButton.isOn = true;
            }

            resetSelectedPages;
            if (firstButton)
            {
                firstButton.isOn = false;
            }

            if (activePageButtons.length == 0)
            {
                return false;
            }

            auto lastActiveButtonIndex = activePageFirstIndex + (activePageButtons.length - 1);
            if (lastActiveButtonIndex >= (numPages - 1))
            {
                auto rest = lastActiveButtonIndex - (numPages - 1);
                auto lastBtns = activePageButtons[$ - rest - 1 .. $];
                foreach (Button lastBtn; lastBtns)
                {
                    if (lastBtn.isVisible)
                    {
                        lastBtn.isVisible = false;
                    }
                }

            }
        }
        else
        {
            size_t activeIndex;

            if (endButton)
            {
                endButton.isOn = false;
            }
            if (firstButton)
            {
                firstButton.isOn = false;
            }

            resetSelectedPages;

            if (current >= activePageFirstIndex)
            {
                activeIndex = current - activePageFirstIndex;

                if (activeIndex >= activePageButtons.length)
                {
                    activePageFirstIndex += activePageButtons.length;
                    activeIndex -= activePageButtons.length;
                }
            }
            else
            {
                activePageFirstIndex -= activePageButtons.length;
                activeIndex = index - activePageFirstIndex;
            }

            updateActiveButtons;

            activePageButtons[activeIndex].isOn = true;
        }

        return true;
    }

    protected void updateActiveButtons()
    {
        foreach (i, Button btn; activePageButtons)
        {
            auto btnIndex = i + activePageFirstIndex;
            if (btnIndex >= (numPages - 1))
            {
                btn.isVisible = false;
                continue;
            }
            auto indexText = (btnIndex + 1).to!dstring;
            btn.text = indexText;
        }
    }

    protected void resetSelectedPages()
    {
        foreach (Button btn; activePageButtons)
        {
            btn.isOn = false;
            if (!btn.isVisible)
            {
                btn.isVisible = true;
            }
        }
    }
}
