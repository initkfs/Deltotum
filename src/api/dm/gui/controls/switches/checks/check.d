module api.dm.gui.controls.switches.checks.check;

import api.dm.gui.controls.switches.base_biswitch : BaseBiswitch;
import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;

/**
 * Authors: initkfs
 */
class Check : BaseBiswitch
{
    protected
    {
        Sprite2d marker;
        Sprite2d markerContainer;
        Sprite2d indeterminate;
    }

    bool isCreateMarker;
    Sprite2d delegate(Sprite2d) onNewMarker;
    void delegate(Sprite2d) onConfiguredMarker;
    void delegate(Sprite2d) onCreatedMarker;

    bool isCreateIndeterminate;
    Sprite2d delegate(Sprite2d) onNewIndeterminate;
    void delegate(Sprite2d) onConfiguredIndeterminate;
    void delegate(Sprite2d) onCreatedIndeterminate;

    double markerWidth = 0;
    double markerHeight = 0;

    bool isCreateMarkerListeners = true;

    this(dstring text = "Check", double width, double height, string iconName = null, double graphicsGap = 5)
    {
        super(text, iconName, graphicsGap, isCreateLayout:
            true);

        initSize(width, height);

        isCreateLabelText = true;
        isCreateMarker = true;
    }

    this(dstring text = "Check", string iconName = null, double graphicsGap = 5)
    {
        this(text, 0, 0, iconName, graphicsGap);
    }

    override void initialize()
    {
        super.initialize;
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadCheckTheme;
    }

    void loadCheckTheme()
    {
        if (markerWidth == 0)
        {
            markerWidth = theme.checkMarkerWidth;
        }
        if (markerHeight == 0)
        {
            markerHeight = theme.checkMarkerHeight;
        }
    }

    Sprite2d newMarkerContainer()
    {
        import api.dm.gui.controls.containers.center_box : CenterBox;

        auto markerContainer = new CenterBox;
        markerContainer.resize(markerWidth, markerHeight);
        markerContainer.isBorder = true;
        return markerContainer;
    }

    Sprite2d newMarker()
    {
        import api.dm.kit.sprites2d.shapes.convex_polygon : ConvexPolygon;
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

        assert(markerWidth > 0);
        assert(markerHeight > 0);

        auto markerStyle = createFillStyle;

        import Math = api.math;

        auto diameter = Math.max(markerWidth / 2, markerHeight / 2);

        auto marker = theme.circleShape(diameter, markerStyle);
        //auto marker = theme.shape(markerWidth / 2, markerHeight / 2, angle, markerStyle);
        return marker;
    }

    Sprite2d newIndeterminateMarker()
    {
        import api.dm.kit.sprites2d.shapes.rectangle : Rectangle;
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

        assert(markerWidth > 0);
        assert(markerHeight > 0);

        const style = createFillStyle;

        auto marker = theme.rectShape(markerWidth / 2, markerHeight / 4, angle, style);
        return marker;
    }

    override void create()
    {
        super.create;

        markerContainer = newMarkerContainer;
        addCreate(markerContainer);

        if (isCreateMarker)
        {
            auto newMarker = newMarker();
            marker = onNewMarker ? onNewMarker(newMarker) : newMarker;

            if (onConfiguredMarker)
            {
                onConfiguredMarker(marker);
            }

            if (markerContainer)
            {
                markerContainer.addCreate(marker);
            }
            else
            {
                addCreate(marker);
            }

            if (onCreatedMarker)
            {
                onCreatedMarker(marker);
            }
        }

        if (isCreateIndeterminate)
        {
            auto newMarker = newIndeterminateMarker();
            indeterminate = onNewIndeterminate ? onNewIndeterminate(newMarker) : newMarker;

            if (onConfiguredIndeterminate)
            {
                onConfiguredIndeterminate(indeterminate);
            }

            if (markerContainer)
            {
                markerContainer.addCreate(indeterminate);
            }
            else
            {
                addCreate(indeterminate);
            }

            if (onCreatedIndeterminate)
            {
                onCreatedIndeterminate(indeterminate);
            }
        }

        //isIndeterminate?
        //markerState(isOn);
        if (indeterminate)
        {
            markerState = false;
            isIndeterminate = true;
        }else {
            markerState = isOn;
            isIndeterminate = false;
        }

        if (isCreateMarkerListeners)
        {
            assert(marker);
            onPointerRelease ~= (ref e) { toggle; };
        }
    }

    bool isIndeterminate() => indeterminate && indeterminate.isVisible;

    bool isIndeterminate(bool value)
    {
        if (!indeterminate)
        {
            return false;
        }

        if (value && marker && marker.isVisible)
        {
            marker.isVisible = false;
        }

        indeterminate.isVisible = value;
        return true;
    }

    protected bool markerState(bool value)
    {
        if (!marker)
        {
            return false;
        }

        marker.isVisible = value;
        return true;
    }

    override bool isOn() => super.isOn;

    override bool isOn(bool value, bool isTriggerListeners = true)
    {
        bool isSetState = super.isOn(value, isTriggerListeners);
        if (isSetState)
        {
            if (isIndeterminate)
            {
                isIndeterminate = false;
            }

            markerState = _state;
        }

        return isSetState;
    }
}
