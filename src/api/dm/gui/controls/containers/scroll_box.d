module api.dm.gui.controls.containers.scroll_box;

import api.dm.gui.controls.containers.container : Container;
import api.dm.kit.sprites2d.layouts.managed_layout : ManagedLayout;
import api.math.geom2.rect2 : Rect2d;

import api.dm.gui.controls.containers.vbox : VBox;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.gui.controls.containers.center_box : CenterBox;
import api.dm.gui.controls.meters.scrolls.hscroll : HScroll;
import api.dm.gui.controls.meters.scrolls.vscroll : VScroll;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.math.pos2.insets : Insets;

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
        Sprite2d contentRoot;

        enum
        {
            idVscroll = "scb_scroll_v",
            idHscroll = "scb_scroll_h"
        }
    }

    ScrollBarPolicy vScrollPolicy = ScrollBarPolicy.ifneed;
    ScrollBarPolicy hScrollPolicy = ScrollBarPolicy.ifneed;

    double clipErrorDelta = 1;
    double clipPadding = 0;

    this(double width = 100, double height = 100)
    {
        this.width = width;
        this.height = height;

        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        isBorder = true;
        layout = new VLayout(0);
        layout.isAlignX = false;
        layout.isAutoResize = true;
        layout.isDecreaseRootSize = true;
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
        contentContainer.layout.isDecreaseRootSize = true;
        contentContainer.isGrow = true;
        addCreate(contentContainer);
        contentContainer.padding = Insets(0);

        content = new CenterBox;
        content.layout.isDecreaseRootSize = true;
        content.isGrow = true;
        contentContainer.addCreate(content);
        content.padding = Insets(0);

        vslider = new VScroll;
        vslider.id = idVscroll;
        vslider.isVGrow = true;
        contentContainer.addCreate(vslider);

        if (vScrollPolicy != ScrollBarPolicy.always)
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

        if (hScrollPolicy != ScrollBarPolicy.always)
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
        if (hScrollPolicy != ScrollBarPolicy.never)
        {
            contentWidth -= vslider.width;
        }

        double contentHeight = height - padding.height;
        if (vScrollPolicy != ScrollBarPolicy.never)
        {
            contentHeight -= hslider.height;
        }
        content.resize(contentWidth, contentHeight);
        //content.isDrawClip = true;

        checkScrolls;

        updateClip;

        onClipResize = (clipPtr) { updateClip; };

        onClipMove = (clipPtr) { updateClip; };

        onPointerWheel ~= (ref e) {
            if (vslider)
            {
                vslider.fireEvent(e);
                e.isConsumed = true;
            }
        };
    }

    double contentWidth()
    {
        if (!content)
        {
            return 0;
        }
        return content.width;
    }

    protected void checkScrolls()
    {
        double errorDelta = 1;
        if (hScrollPolicy == ScrollBarPolicy.ifneed && content)
        {
            assert(content);
            if (contentRoot && (contentRoot.width - errorDelta) > content.width)
            {
                enableScroll(hslider);
            }
            else
            {
                disableScroll(hslider);
            }
        }

        if (vScrollPolicy == ScrollBarPolicy.ifneed && content)
        {
            assert(content);
            if (contentRoot && (contentRoot.height - errorDelta) > content.height)
            {
                enableScroll(vslider);
            }
            else
            {
                disableScroll(vslider);
            }
        }
    }

    protected void disableScroll(Sprite2d scroll)
    {
        scroll.isVisible = false;
        scroll.isLayoutManaged = false;
        scroll.isResizedByParent = false;
    }

    protected void enableScroll(Sprite2d scroll)
    {
        scroll.isVisible = true;
        scroll.isLayoutManaged = true;
        scroll.isResizedByParent = true;
    }

    protected void updateClip()
    {
        content.clip = Rect2d(
            (content.x - clipErrorDelta) + clipPadding,
            content.y - clipErrorDelta + clipPadding,
            content.width - clipPadding + clipErrorDelta * 2, content
                .height + clipErrorDelta * 2 - clipPadding);
        content.isMoveClip = true;
        content.isResizeClip = true;

        if (contentRoot)
        {
            contentRoot.onChildrenRec = (child) {
                child.clip = content.clip;
                child.isMoveClip = false;
                child.isResizeClip = false;
                return true;
            };
        }
    }

    void setContent(Sprite2d root, double newWidth = 0, double newHeight = 0)
    {
        assert(root);
        assert(content);

        if (root.isLayoutManaged)
        {
            root.isLayoutManaged = false;
            //TODO hack for process events
        }

        if(root.isResizedByParent){
            root.isResizedByParent = false;
        }

        if (contentRoot)
        {
            //TODO destroy?
            content.remove(contentRoot, true);
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

        if (newWidth > 0)
        {
            content.width = newWidth;
        }

        if (newHeight > 0)
        {
            content.height = newHeight;
        }

        checkScrolls;
    }

    override void dispose()
    {
        // if (contentRoot)
        // {
        //     content.remove(contentRoot, false);
        // }
        //contentRoot = null;
        super.dispose;
    }

}
