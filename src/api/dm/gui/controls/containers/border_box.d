module api.dm.gui.controls.containers.border_box;

import api.dm.gui.controls.containers.container : Container;

/**
 * Authors: initkfs
 */
class BorderBox : Container
{
    Container _top;
    bool isCreateTop = true;
    Container delegate(Container) onNewTop;
    void delegate(Container) onConfiguredTop;
    void delegate(Container) onCreatedTop;

    Container _left;
    bool isCreateLeft = true;
    Container delegate(Container) onNewLeft;
    void delegate(Container) onConfiguredLeft;
    void delegate(Container) onCreatedLeft;

    Container _center;
    bool isCreateCenter = true;
    Container delegate(Container) onNewCenter;
    void delegate(Container) onConfiguredCenter;
    void delegate(Container) onCreatedCenter;

    Container _right;
    bool isCreateRight = true;
    Container delegate(Container) onNewRight;
    void delegate(Container) onConfiguredRight;
    void delegate(Container) onCreatedRight;

    Container _bottom;
    bool isCreateBottom = true;
    Container delegate(Container) onNewBottom;
    void delegate(Container) onConfiguredBottom;
    void delegate(Container) onCreatedBottom;

    Container _centerContainer;
    Container delegate(Container) onNewCenterContainer;
    void delegate(Container) onConfiguredCenterContainer;
    void delegate(Container) onCreatedCenterContainer;

    this()
    {
        import api.dm.kit.sprites2d.layouts.vlayout: VLayout;
        
        layout = new VLayout(0);
        layout.isAutoResize = true;
        layout.isAlignX = true;
    }

    override void create()
    {
        super.create;

        if (!_top && isCreateTop)
        {
            auto container = newTop;
            _top = !onNewTop ? container : onNewTop(container);
            if (onConfiguredTop)
            {
                onConfiguredTop(_top);
            }

            addCreate(_top);

            if (onCreatedTop)
            {
                onCreatedTop(_top);
            }
        }

        if (!_centerContainer)
        {
            auto container = newCenterContainer;
            _centerContainer = !onNewCenterContainer ? container : onNewCenterContainer(container);

            if (_centerContainer.layout)
            {
                _centerContainer.layout.isAutoResize = true;
                _centerContainer.layout.isAlignY = true;
            }

            if (onConfiguredCenterContainer)
            {
                onConfiguredCenterContainer(_centerContainer);
            }

            addCreate(_centerContainer);
            if (onCreatedCenterContainer)
            {
                onCreatedCenterContainer(_centerContainer);
            }
        }

        if (!_left && isCreateLeft)
        {
            auto container = newLeft;
            _left = !onNewLeft ? container : onNewLeft(container);
            if (onConfiguredLeft)
            {
                onConfiguredLeft(_left);
            }

            _centerContainer.addCreate(_left);

            if (onCreatedLeft)
            {
                onCreatedLeft(_left);
            }
        }

        if (!_center && isCreateCenter)
        {
            auto container = newCenter;
            _center = !onNewCenter ? container : onNewCenter(container);
            if (onConfiguredCenter)
            {
                onConfiguredCenter(_center);
            }

            _centerContainer.addCreate(_center);

            if (onCreatedCenter)
            {
                onCreatedCenter(_center);
            }
        }

        if (!_right && isCreateRight)
        {
            auto container = newRight;
            _right = !onNewRight ? container : onNewRight(container);
            if (onConfiguredRight)
            {
                onConfiguredRight(_right);
            }

            _centerContainer.addCreate(_right);

            if (onCreatedRight)
            {
                onCreatedRight(_right);
            }
        }

        if (!_bottom && isCreateBottom)
        {
            auto container = newBottom;
            _bottom = !onNewBottom ? container : onNewBottom(container);
            if (onConfiguredBottom)
            {
                onConfiguredBottom(_bottom);
            }

            addCreate(_bottom);

            if (onCreatedBottom)
            {
                onCreatedBottom(_bottom);
            }
        }
    }

    Container topBox()
    out (_top; _top !is null) => _top;

    Container rightBox()
    out (_right; _right !is null) => _right;

    Container centerBox()
    out (_center; _center !is null) => _center;

    Container bottomBox()
    out (_bottom; _bottom !is null) => _bottom;

    Container leftBox()
    out (_left; _left !is null) => _left;

    protected Container newContainer()
    {
        auto container = new Container;

        import api.dm.kit.sprites2d.layouts.center_layout : CenterLayout;

        container.layout = new CenterLayout;
        container.layout.isAutoResize = true;
        return container;
    }

    Container newCenterContainer()
    {
        import api.dm.gui.controls.containers.hbox : HBox;

        return new HBox(0);
    }

    Container newTop() => newContainer;
    Container newCenter() => newContainer;
    Container newLeft() => newContainer;
    Container newBottom() => newContainer;
    Container newRight() => newContainer;
}
