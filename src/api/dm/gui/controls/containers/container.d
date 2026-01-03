module api.dm.gui.controls.containers.container;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;

/**
 * Authors: initkfs
 */
class Container : Control
{

    this()
    {

    }

    bool isAlignX()
    {
        if (!layout)
        {
            return false;
        }

        return layout.isAlignX;
    }

    bool isAlignX(bool value)
    {
        if (!layout)
        {
            return false;
        }

        layout.isAlignX = value;
        setInvalid;
        return true;
    }

    bool isAlignY()
    {
        if (!layout)
        {
            return false;
        }

        return layout.isAlignY;
    }

    bool isAlignY(bool value)
    {
        if (!layout)
        {
            return false;
        }

        layout.isAlignY = value;
        setInvalid;
        return true;
    }

    bool isFillStartToEnd()
    {
        if (!layout)
        {
            return false;
        }

        return layout.isFillStartToEnd;
    }

    bool isFillStartToEnd(bool isFill)
    {
        if (!layout)
        {
            return false;
        }

        layout.isFillStartToEnd = isFill;
        setInvalid;
        return true;
    }

    bool isLayoutResizeChildren()
    {
        if (!layout)
        {
            return false;
        }
        return layout.isResizeChild;
    }

    bool isLayoutResizeChildren(bool value)
    {
        if (!layout)
        {
            return false;
        }

        layout.isResizeChild = value;
        setInvalid;
        return true;
    }

    bool isResizeRoot()
    {
        if (!layout)
        {
            return false;
        }

        return layout.isResizeRoot;
    }

    bool isResizeRoot(bool value)
    {
        if (!layout)
        {
            return false;
        }

        layout.isIncreaseRootSize = value;
        setInvalid;
        return true;
    }
}