module api.dm.gui.controls.containers.circle_box;

import api.dm.gui.controls.containers.container : Container;

/**
 * Authors: initkfs
 */
class CircleBox : Container
{
    protected
    {
        float _radius = 0;
        float _startAngle = 0;
        float _innerPadding = 0;
    }

    this(float radius = 0, float startAngle = 0)
    {
        this._radius = radius;

        if (_radius > 0)
        {
            auto diameter = _radius * 2;
            initSize(diameter, diameter);
        }

        _startAngle = startAngle;

        import api.dm.kit.sprites2d.layouts.circle_layout : CircleLayout;

        layout = new CircleLayout(layoutRadius, _startAngle);
        layout.isAutoResize = true;

        isBorder = true;
    }

    protected float layoutRadius()
    {
        float innerRadius = _radius - _innerPadding;
        if (innerRadius < 0)
        {
            innerRadius = _radius;
        }
        return innerRadius;
    }

    //TODO invalidation
    protected void tryUpdateCircleLayout()
    {
        import api.dm.kit.sprites2d.layouts.circle_layout : CircleLayout;

        if (auto circleLayout = cast(CircleLayout) layout)
        {
            circleLayout.radius = layoutRadius;
        }
    }

    void radius(float v)
    {
        _radius = v;
        tryUpdateCircleLayout;
    }

    void innerPadding(float p)
    {
        _innerPadding = p;
        tryUpdateCircleLayout;
    }

    void startAngle(float v)
    {
        _startAngle = v;

        import api.dm.kit.sprites2d.layouts.circle_layout : CircleLayout;

        if (auto circleLayout = cast(CircleLayout) layout)
        {
            circleLayout.startAngle = _startAngle;
        }
    }

    float diameter() => _radius * 2;

    override void loadTheme()
    {
        super.loadTheme;

        if (_radius == 0)
        {
            radius = theme.meterThumbDiameter;
        }

        if (diameter > width)
        {
            initWidth = diameter;
        }

        if (diameter > height)
        {
            initHeight = diameter;
        }
    }
}
