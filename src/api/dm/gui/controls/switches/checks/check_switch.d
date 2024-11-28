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
    }

    bool isCreateMarker;
    Sprite delegate(Sprite) onMarkerCreate;
    void delegate(Sprite) onMarkerCreated;

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

    Sprite newMarker()
    {
        import api.dm.gui.containers.stack_box : StackBox;

        import api.dm.kit.sprites.shapes.convex_polygon : ConvexPolygon;
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
        import api.dm.gui.containers.stack_box : StackBox;

        assert(markerWidth > 0);
        assert(markerHeight > 0);

        auto marker = new ConvexPolygon(markerWidth / 2, markerHeight / 2, GraphicStyle(1, theme.colorAccent, true, theme
                .colorAccent), 3);

        auto markerContainer = new class StackBox
        {
            this()
            {
                super(markerWidth, markerHeight);
            }

            override void isVisible(bool value)
            {
                marker.isVisible = value;
            }
        };

        markerContainer.isBorder = true;
        buildInitCreate(markerContainer);

        markerContainer.addCreate(marker);
        return markerContainer;
    }

    override void create()
    {
        super.create;

        if (isCreateMarker)
        {
            auto newMarker = newMarker();
            marker = onMarkerCreate ? onMarkerCreate(newMarker) : newMarker;
            addCreate(marker);
            if (onMarkerCreated)
            {
                onMarkerCreated(marker);
            }

            markerState(isOn);
        }

        if (isCreateMarkerListeners)
        {
            assert(marker);
            onPointerUp ~= (ref e) { toggle; };
        }
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
        if (isSetState && marker)
        {
            markerState = _state;
        }

        return isSetState;
    }
}
