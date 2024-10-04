module api.dm.gui.containers.scroll_box;

import api.dm.gui.containers.container : Container;
import api.dm.kit.sprites.layouts.managed_layout : ManagedLayout;
import api.math.geom2.rect2 : Rect2d;

import api.dm.gui.containers.vbox : VBox;
import api.dm.gui.containers.hbox : HBox;
import api.dm.gui.containers.stack_box : StackBox;
import api.dm.gui.controls.scrolls.hscroll : HScroll;
import api.dm.gui.controls.scrolls.vscroll : VScroll;
import api.dm.kit.sprites.sprite : Sprite;
import api.math.insets : Insets;

enum ScrollBarPolicy
{
    never,
    always,
    ifneed
}

/**
 * Authors: initkfs
 */
class ScrollBox : Container
{
    protected
    {
        VScroll vslider;
        HScroll hslider;
        Container content;
        Container contentContainer;
        Sprite contentRoot;

        enum {
            idVscroll = "scb_scroll_v",
            idHscroll = "scb_scroll_h"
        }

        ScrollBarPolicy _vScrollPolicy = ScrollBarPolicy.ifneed;
        ScrollBarPolicy _hScrollPolicy = ScrollBarPolicy.ifneed;
    }

    this(double width = 100, double height = 100)
    {
        this.width = width;
        this.height = height;

        import api.dm.kit.sprites.layouts.vlayout : VLayout;

        isBorder = true;
        layout = new VLayout(0);
        layout.isAlignX = false;
        layout.isAutoResize = true;
    }

    override void initialize()
    {
        super.initialize;
    }

    override void create()
    {
        super.create;

        invalidateListeners ~= () {
            if (!isCreated)
            {
                return;
            }
            checkScrolls;
            updateClip;
        };

        padding = Insets(0);

        contentContainer = new HBox(0);
        contentContainer.isGrow = true;
        addCreate(contentContainer);
        contentContainer.padding = Insets(0);

        content = new StackBox;
        content.isGrow = true;
        contentContainer.addCreate(content);
        content.padding = Insets(0);

        vslider = new VScroll;
        vslider.id = idVscroll;
        vslider.isVGrow = true;
        contentContainer.addCreate(vslider);

        if (_vScrollPolicy != ScrollBarPolicy.always)
        {
            disableScroll(vslider);
        }

        vslider.onValue ~= (double val) {
            import Math = api.dm.math;

            if (!contentRoot)
            {
                return;
            }

            double viewDt = contentRoot.height - content.height;
            double needContentYOffset = viewDt * val;
            double yDt = content.y - contentRoot.y;
            double dtY = needContentYOffset - yDt;
            contentRoot.y = contentRoot.y - dtY;
        };

        hslider = new HScroll;
        hslider.id = idHscroll;
        hslider.isHGrow = true;
        addCreate(hslider);

        if (_hScrollPolicy != ScrollBarPolicy.always)
        {
            disableScroll(hslider);
        }

        hslider.onValue ~= (val) {
            if (!contentRoot)
            {
                return;
            }
            double viewDt = contentRoot.width - content.width;
            double needContentXOffset = viewDt * val;
            double xDt = content.x - contentRoot.x;
            double dtX = needContentXOffset - xDt;
            contentRoot.x = contentRoot.x - dtX;
        };

        //TODO from layout
        double spacing = 0;

        //TODO slider if layout managed = false
        double contentWidth = width - spacing - padding.width;
        if (_hScrollPolicy != ScrollBarPolicy.never)
        {
            contentWidth -= vslider.width;
        }

        double contentHeight = height - padding.height;
        if (_vScrollPolicy != ScrollBarPolicy.never)
        {
            contentHeight -= hslider.height;
        }
        content.resize(contentWidth, contentHeight);

        checkScrolls;

        updateClip;

        onClipResize = (clipPtr) { clipChildren(contentRoot); };

        onClipMove = (clipPtr) { clipChildren(contentRoot); };
    }

    protected void checkScrolls()
    {
        if (_hScrollPolicy == ScrollBarPolicy.ifneed && !hslider.isVisible)
        {
            assert(content);
            if (contentRoot && contentRoot.width > content.width)
            {
                 enableScroll(hslider);
            }
        }

        if (_vScrollPolicy == ScrollBarPolicy.ifneed && !vslider.isVisible)
        {
            assert(content);
            if (contentRoot && contentRoot.height > content.height)
            {
                 enableScroll(vslider);
            }
        }
    }

    protected void disableScroll(Sprite scroll)
    {
        scroll.isVisible = false;
        scroll.isLayoutManaged = false;
        scroll.isResizedByParent = false;
    }

    protected void enableScroll(Sprite scroll)
    {
        scroll.isVisible = true;
        scroll.isLayoutManaged = true;
        scroll.isResizedByParent = true;
    }

    protected void updateClip()
    {
        enum clipPadding = 3;
        content.clip = Rect2d(content.x + clipPadding, content.y + clipPadding, content.width - clipPadding, content
                .height - clipPadding);
        content.isMoveClip = true;
        content.isResizeClip = true;
    }

    protected void clipChildren(Sprite root)
    {
        root.onChildrenRec = (child) {
            child.clip = clip;
            child.isMoveClip = false;
            child.isResizeClip = false;
            return true;
        };
    }

    void setContent(Sprite root)
    {
        assert(content);

        if (root.isLayoutManaged)
        {
            root.isLayoutManaged = false;
            //TODO hack for process events
            clipChildren(root);
        }

        if (contentRoot)
        {
            //TODO destroy?
            content.remove(contentRoot, false);
        }

        contentRoot = root;
        if (!contentRoot.isCreated)
        {
            content.addCreate(contentRoot);
        }
        else
        {
            content.add(contentRoot);
        }

        checkScrolls;
    }

    override void dispose(){
        if (contentRoot)
        {
            content.remove(contentRoot, false);
        }
        contentRoot = null;
        super.dispose;
    }

}
