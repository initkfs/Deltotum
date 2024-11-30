module api.dm.gui.controls.switches.checks.check_switch;

import api.dm.gui.controls.switches.base_biswitch : BaseBiswitch;
import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
class CheckSwitch : BaseBiswitch
{
    protected
    {
        Sprite marker;
        Sprite markerContainer;
        Sprite indeterminate;
    }

    bool isCreateMarker;
    Sprite delegate(Sprite) onMarkerCreate;
    void delegate(Sprite) onMarkerCreated;

    bool isCreateIndeterminate = true;
    Sprite delegate(Sprite) onIndeterminateCreate;
    void delegate(Sprite) onIndeterminateCreated;

    double markerWidth = 0;
    double markerHeight = 0;

    void delegate(bool, bool)[] onOldNewValue;

    bool isCreateMarkerListeners = true;

    this(dstring text = "CheckSwitch", double width, double height, string iconName = null, double graphicsGap = 5)
    {
        super(width, height, text, iconName, graphicsGap, isCreateLayout:
            true);

        isCreateLabelText = true;
        isCreateMarker = true;
    }

    this(dstring text = "CheckSwitch", string iconName = null, double graphicsGap = 5)
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

    Sprite newMarkerContainer()
    {
        import api.dm.gui.containers.stack_box : StackBox;

        auto markerContainer = new StackBox;
        markerContainer.resize(markerWidth, markerHeight);
        markerContainer.isBorder = true;
        return markerContainer;
    }

    Sprite newMarker()
    {
        import api.dm.kit.sprites.shapes.convex_polygon : ConvexPolygon;
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

        assert(markerWidth > 0);
        assert(markerHeight > 0);

        auto marker = new ConvexPolygon(markerWidth / 2, markerHeight / 2, GraphicStyle(1, theme.colorAccent, true, theme
                .colorAccent), 3);
        return marker;
    }

    Sprite newIndeterminateMarker()
    {
        import api.dm.kit.sprites.shapes.rectangle : Rectangle;
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

        assert(markerWidth > 0);
        assert(markerHeight > 0);

        auto marker = new Rectangle(markerWidth / 2, 5, GraphicStyle(1, theme.colorAccent, true, theme
                .colorAccent));
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
            marker = onMarkerCreate ? onMarkerCreate(newMarker) : newMarker;
            if (markerContainer)
            {
                markerContainer.addCreate(marker);
            }
            else
            {
                addCreate(marker);
            }
            if (onMarkerCreated)
            {
                onMarkerCreated(marker);
            }
        }

        if (isCreateIndeterminate)
        {
            auto newMarker = newIndeterminateMarker();
            indeterminate = onIndeterminateCreate ? onIndeterminateCreate(newMarker) : newMarker;
            if (markerContainer)
            {
                markerContainer.addCreate(indeterminate);
            }
            else
            {
                addCreate(indeterminate);
            }
            if (onIndeterminateCreated)
            {
                onIndeterminateCreated(indeterminate);
            }
        }

        //isIndeterminate?
        //markerState(isOn);
        if (indeterminate)
        {
            markerState = false;
            isIndeterminate = true;
        }

        if (isCreateMarkerListeners)
        {
            assert(marker);
            onPointerUp ~= (ref e) { toggle; };
        }
    }

    bool isIndeterminate() => indeterminate && indeterminate.isVisible;

    bool isIndeterminate(bool value)
    {
        if (!indeterminate)
        {
            return false;
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

    override bool isOn(bool value, bool isRunListeners = true)
    {
        bool isSetState = super.isOn(value, isRunListeners);
        if (isSetState)
        {
            if(isIndeterminate){
                isIndeterminate = false;
            }

            markerState = _state;
        }

        return isSetState;
    }
}
