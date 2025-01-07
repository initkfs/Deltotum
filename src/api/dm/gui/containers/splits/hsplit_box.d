module api.dm.gui.containers.splits.hsplit_box;

import api.dm.gui.containers.splits.base_split_box : BaseSplitBox, DividerData;
import api.dm.gui.containers.container : Container;
import api.dm.kit.sprites2d.layouts.hlayout : HLayout;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;

/**
 * Authors: initkfs
 */
class HSplitBox : BaseSplitBox
{
    this()
    {
        layout = new HLayout(0);
        layout.isAutoResize = true;
    }

    protected
    {

    }

    override void create()
    {
        super.create;

        window.showingTasks ~= (dt) {
            foreach (sepData; dividers)
            {
                Sprite2d left = sepData.prev;
                sepData.sep.x = left.boundsRect.right - sepData.sep.boundsRect.halfWidth;
            }
        };
    }

    override void applyLayout()
    {
        super.applyLayout;

        foreach (sdata; dividers)
        {
            if (sdata.sep.height != height)
            {
                sdata.sep.height = height;
            }
        }
    }

    override double dividerWidth() => dividerSize;
    override double dividerHeight() => height - padding.height;

    override bool delegate(double, double) newOnSepDragXY(Sprite2d sep)
    {
        return (x, y) {

            auto sepData = findDividerUnsafe(sep);
            if (!sepData)
            {
                //TODO log?
                return false;
            }

            auto prev = sepData.prev;
            auto next = sepData.next;

            //auto bounds = this.boundsRect;
            const minX = prev.x;
            const maxX = next.boundsRect.right - sep.width;
            if (x <= minX || x >= maxX)
            {
                return false;
            }

            auto dx = sep.x - x;
            if (dx == 0)
            {
                return false;
            }

            sep.x = x;

            prev.isResizeChildren = true;
            prev.isResizeChildrenAlways = true;
            next.isResizeChildren = true;
            next.isResizeChildrenAlways = true;

            if (dx > 0)
            {
                //to left
                if (prev.layout)
                {
                    prev.layout.isIncreaseRootSize = false;
                    prev.layout.isResizeChildren = false;
                }

                if (next.layout)
                {
                    next.layout.isIncreaseRootSize = true;
                    next.layout.isResizeChildren = true;
                }
            }
            else
            {
                //to right
                if (next.layout)
                {
                    next.layout.isIncreaseRootSize = false;
                    next.layout.isResizeChildren = false;
                }

                if (prev.layout)
                {
                    prev.layout.isIncreaseRootSize = true;
                    prev.layout.isResizeChildren = true;
                }
            }

            prev.width = prev.width - dx;
            next.width = next.width + dx;

            if (onMoveDivider)
            {
                onMoveDivider(*sepData);
            }

            return false;
        };
    }
}
