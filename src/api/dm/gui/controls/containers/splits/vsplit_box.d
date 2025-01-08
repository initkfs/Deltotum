module api.dm.gui.controls.containers.splits.vsplit_box;

import api.dm.gui.controls.containers.splits.base_split_box : BaseSplitBox, DividerData;
import api.dm.gui.controls.containers.container : Container;
import api.dm.kit.sprites2d.layouts.vlayout : VLayout;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;

/**
 * Authors: initkfs
 */
class VSplitBox : BaseSplitBox
{
    this()
    {
        layout = new VLayout(0);
        layout.isAutoResize = true;
    }

    override double dividerWidth() => width - padding.width;
    override double dividerHeight() => dividerSize;

    override void create()
    {
        super.create;

        window.showingTasks ~= (dt) {
            foreach (sepData; dividers)
            {
                Sprite2d prev = sepData.prev;
                sepData.sep.y = prev.boundsRect.bottom - sepData.sep.boundsRect.halfHeight;
            }

        };
    }

    override void applyLayout()
    {
        super.applyLayout;

        foreach (sdata; dividers)
        {
            if (sdata.sep.width != width)
            {
                sdata.sep.width = width;
            }
        }
    }

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
            const minY = prev.y;
            const maxY = next.boundsRect.bottom - sep.height;
            if (y <= minY || y >= maxY)
            {
                return false;
            }

            auto dy = sep.y - y;
            if (dy == 0)
            {
                return false;
            }

            sep.y = y;

            prev.isResizeChildren = true;
            next.isResizeChildren = true;

            if (dy > 0)
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

            prev.height = prev.height - dy;
            next.height = next.height + dy;

            if (onMoveDivider)
            {
                onMoveDivider(*sepData);
            }

            return false;
        };
    }
}
