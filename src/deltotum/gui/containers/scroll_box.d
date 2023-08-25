module deltotum.gui.containers.scroll_box;

import deltotum.gui.containers.container : Container;
import deltotum.kit.sprites.layouts.managed_layout : ManagedLayout;
import deltotum.math.shapes.rect2d : Rect2d;

import deltotum.gui.containers.vbox : VBox;
import deltotum.gui.containers.hbox : HBox;
import deltotum.gui.containers.stack_box : StackBox;
import deltotum.gui.controls.sliders.hslider : HSlider;
import deltotum.gui.controls.sliders.vslider : VSlider;
import deltotum.kit.sprites.sprite : Sprite;
import deltotum.math.geom.insets : Insets;

/**
 * Authors: initkfs
 */
class ScrollBox : VBox
{
    protected
    {
        VSlider vslider;
        HSlider hslider;
        StackBox content;
        HBox contentContainer;
        Sprite contentRoot;
    }

    this()
    {

    }

    override void initialize()
    {
        super.initialize;
    }

    override void create()
    {
        super.create;

        padding = Insets(0);
        spacing = 0;

        contentContainer = new HBox(0);
        addCreate(contentContainer);
        contentContainer.padding = Insets(0);

        content = new StackBox;
        contentContainer.addCreate(content);

        vslider = new VSlider;
        vslider.isVGrow = true;
        contentContainer.addCreate(vslider);

        vslider.onValue = (double val) {
            import Math = deltotum.math;

            double viewDt = contentRoot.height - content.height;
            double needContentYOffset = viewDt * val;
            double yDt = content.y - contentRoot.y;
            double dtY = needContentYOffset - yDt;
            contentRoot.y = contentRoot.y - dtY;
        };

        hslider = new HSlider;
        hslider.isHGrow = true;
        addCreate(hslider);

        hslider.onValue = (val) {
            double viewDt = contentRoot.width - content.width;
            double needContentXOffset = viewDt * val;
            double xDt = content.x - contentRoot.x;
            double dtX = needContentXOffset - xDt;
            contentRoot.x = contentRoot.x - dtX;
        };

        content.resize(width - spacing - vslider.width - padding.width, height - hslider.height);

        enum clipPadding = 3;
        content.clip = Rect2d(content.x + clipPadding, content.y + clipPadding, content.width - clipPadding, content
                .height - clipPadding);
        content.isMoveClip = true;
        content.isResizeClip = true;

        onClipResize = (clipPtr){
            clipChildren(contentRoot);
        };

        onClipMove = (clipPtr){
            clipChildren(contentRoot);
        };
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
            content.remove(contentRoot);
        }

        contentRoot = root;
        content.addCreate(contentRoot);
    }

}
