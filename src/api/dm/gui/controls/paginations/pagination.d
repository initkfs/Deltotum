module api.dm.gui.controls.paginations.pagination;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.gui.controls.buttons.button : Button;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.containers.container : Container;
import api.dm.kit.sprites.layouts.hlayout : HLayout;
import api.dm.kit.sprites.layouts.vlayout : VLayout;

import std.conv : to;

/**
 * Authors: initkfs
 */
class Pagination : Control
{
    void delegate(size_t) pageFactory;

    protected
    {
        size_t numPages;
        size_t currPageIndex;
        size_t activePagesFirstIndex;
    }

    Container pageIndexContainer;
    Text pageCurrentLabel;
    Button endPage;
    Button firstPage;
    Button currentPage;
    Button[] activePages;
    Text currentPageField;

    size_t activePageCount = 3;

    //TODO numPages == 1, 0, etc
    this(size_t numPages = 10)
    {
        this.numPages = numPages;

        import api.dm.kit.sprites.layouts.hlayout : HLayout;

        this.layout = new VLayout(2);
        layout.isAlignX = true;
        layout.isAutoResize = true;
    }

    override void create()
    {
        super.create;

        pageIndexContainer = new Container;
        pageIndexContainer.layout = new HLayout(5);
        pageIndexContainer.layout.isAutoResize = true;
        pageIndexContainer.layout.isAlignX = true;
        addCreate(pageIndexContainer);

        Button prevButton = createPageButton("<");
        pageIndexContainer.addCreate(prevButton);

        prevButton.onAction ~= (ref e) {
            if (currPageIndex == 0)
            {
                return;
            }
            auto newIndex = currPageIndex - 1;
            assert(pageIndex(newIndex));
        };

        firstPage = createPageButton("1");
        pageIndexContainer.addCreate(firstPage);
        firstPage.onAction ~= (ref e) { setFirstPage; };

        immutable dstring skipPlacelolder = ".";

        pageIndexContainer.addCreate(new Text(skipPlacelolder));

        activePagesFirstIndex = 1;

        foreach (_i; 0 .. activePageCount)
            (size_t i) {
            auto activePage = createPageButton((i + activePagesFirstIndex + 1).to!dstring);
            activePages ~= activePage;
            pageIndexContainer.addCreate(activePage);

            activePage.onAction ~= (ref e) {
                auto pi = i + activePagesFirstIndex;
                assert(pageIndex(pi));
            };

        }(_i);

        pageIndexContainer.addCreate(new Text(skipPlacelolder));

        endPage = createPageButton(numPages.to!dstring);
        pageIndexContainer.addCreate(endPage);
        endPage.onAction ~= (ref e) { setLastPage; };

        Button nextButton = createPageButton(">");
        pageIndexContainer.addCreate(nextButton);

        nextButton.onAction ~= (ref e) {
            auto newIndex = currPageIndex + 1;
            if (newIndex >= numPages)
            {
                return;
            }
            assert(pageIndex(newIndex));
        };

        import api.dm.gui.containers.hbox : HBox;

        auto infoContainer = new HBox(3);
        infoContainer.layout.isAlignY = true;
        addCreate(infoContainer);
        currentPageField = new Text("0");
        currentPageField.isEditable = true;
        currentPageField.isBorder = true;
        currentPageField.width = 40;
        infoContainer.addCreate(currentPageField);
        currentPageField.enableInsets;

        currentPageField.onKeyDown ~= (ref e) {
            import api.dm.com.inputs.com_keyboard : ComKeyName;

            if (e.keyName == ComKeyName.RETURN)
            {
                auto newPage = currentPageField.text.to!size_t;
                if (newPage == 0 && newPage >= numPages)
                {
                    return;
                }

                auto newPageIndex = newPage - 1;

                if(newPageIndex == 0){
                    setFirstPage;
                }else if(newPageIndex == numPages - 1){
                    setLastPage;
                }else {
                    size_t pageCount = newPageIndex / activePageCount;
                    auto pageFirstIndex = 1 + (pageCount) * activePages.length;
                    activePagesFirstIndex = pageFirstIndex;
                    updateActiveButtons;
                    pageIndex(newPageIndex);
                }
                
            }
        };

        pageCurrentLabel = new Text();
        infoContainer.addCreate(pageCurrentLabel);

        pageIndex = 0;
    }

    protected void setFirstPage()
    {
        auto newIndex = 0;
        activePagesFirstIndex = newIndex + 1;
        updateActiveButtons;
        pageIndex(newIndex);
    }

    void setLastPage()
    {
        auto newIndex = numPages - 1;
        auto pagesCount = numPages / activePages.length;
        auto lastPageIndex = 1 + (pagesCount - 1) * activePages.length;
        // auto newIndexOffset = pagesCount * activePages.length;
        activePagesFirstIndex = lastPageIndex;
        updateActiveButtons;
        pageIndex(newIndex);
    }

    protected Button createPageButton(dstring text)
    {
        auto button = new Button(text);
        button.width = 20;
        button.height = 20;
        return button;
    }

    bool pageIndex(size_t index)
    {

        if (index >= numPages)
        {
            return false;
        }

        currPageIndex = index;
        if (pageFactory)
        {
            pageFactory(currPageIndex);
        }

        if (currentPageField)
        {
            currentPageField.text = (currPageIndex + 1).to!dstring;
        }

        if (pageCurrentLabel)
        {
            import std.format : format;

            pageCurrentLabel.text = format("/%s", numPages);
        }

        resetSelectedPages;

        if (index == 0)
        {
            firstPage.isSelected = true;
        }
        else if (index == numPages - 1)
        {
            endPage.isSelected = true;

            auto lastActiveButtonIndex = activePagesFirstIndex + (activePages.length - 1);
            if (lastActiveButtonIndex >= (numPages - 1))
            {
                auto rest = lastActiveButtonIndex - (numPages - 1);
                auto lastBtns = activePages[$ - rest - 1 .. $];
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

            if (index >= activePagesFirstIndex)
            {
                activeIndex = index - activePagesFirstIndex;

                if (activeIndex >= activePages.length)
                {
                    activePagesFirstIndex += activePages.length;
                    activeIndex -= activePages.length;
                }
            }
            else
            {
                activePagesFirstIndex -= activePages.length;
                activeIndex = index - activePagesFirstIndex;
            }

            updateActiveButtons;

            activePages[activeIndex].isSelected = true;
        }

        return true;
    }

    protected void updateActiveButtons()
    {
        foreach (i, Button btn; activePages)
        {
            auto btnIndex = i + activePagesFirstIndex;
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
        assert(firstPage);
        assert(endPage);
        firstPage.isSelected = false;
        endPage.isSelected = false;

        foreach (Button btn; activePages)
        {
            btn.isSelected = false;
            if (!btn.isVisible)
            {
                btn.isVisible = true;
            }
        }
    }
}
