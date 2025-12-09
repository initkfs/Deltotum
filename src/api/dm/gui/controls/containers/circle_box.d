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

        layout = new CircleLayout(_radius, _startAngle);
        layout.isAutoResize = true;

        isBorder = true;
    }

    void radius(float v)
    {

        _radius = v;

        import api.dm.kit.sprites2d.layouts.circle_layout : CircleLayout;

        if (auto circleLayout = cast(CircleLayout) layout)
        {
            circleLayout.radius = _radius;
        }
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
