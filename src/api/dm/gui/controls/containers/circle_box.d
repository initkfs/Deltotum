module api.dm.gui.controls.containers.circle_box;

import api.dm.gui.controls.containers.container : Container;

/**
 * Authors: initkfs
 */
class CircleBox : Container
{
    protected
    {
        double _radius = 0;
        double _startAngle = 0;
    }

    this(double radius = 0, double startAngle = 0)
    {
        this._radius = radius;

        if (_radius > 0)
        {
            auto diameter = _radius * 2;
            initSize(diameter, diameter);
        }

        _startAngle = startAngle;

        import api.dm.kit.sprites2d.layouts.circle_layout : CircleLayout;

        layout = new CircleLayout(_radius, _startAngle);
        layout.isAutoResize = true;

        isBorder = true;
    }

    void radius(double v)
    {

        _radius = v;

        import api.dm.kit.sprites2d.layouts.circle_layout : CircleLayout;

        if (auto circleLayout = cast(CircleLayout) layout)
        {
            circleLayout.radius = _radius;
        }
    }

    void startAngle(double v)
    {
        _startAngle = v;

        import api.dm.kit.sprites2d.layouts.circle_layout : CircleLayout;

        if (auto circleLayout = cast(CircleLayout) layout)
        {
            circleLayout.startAngle = _startAngle;
        }
    }

    double diameter() => _radius * 2;

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
