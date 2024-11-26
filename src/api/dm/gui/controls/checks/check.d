module api.dm.gui.controls.checks.check;

import api.dm.gui.controls.labeled : Labeled;
import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
class Check : Labeled
{
    protected
    {
        Sprite marker;
        bool _state;
    }

    bool isCreateMarkerFactory;
    Sprite delegate() markerFactory;
    Sprite delegate(Sprite) onMarkerCreate;
    void delegate(Sprite) onMarkerCreated;

    double markerWidth = 0;
    double markerHeight = 0;

    void delegate(bool, bool)[] onOldNewValue;

    bool isCreateMarkerListeners = true;

    this(dstring text = "Check", double width, double height, string iconName = null, double graphicsGap = 5)
    {
        super(width, height, iconName, graphicsGap, text, isCreateLayout:
            true);

        isCreateTextFactory = true;
        isCreateMarkerFactory = true;

        isBorder = true;
    }

    this(dstring text = "Check", string iconName = null, double graphicsGap = 5)
    {
        this(text, 0, 0, iconName, graphicsGap);
    }

    override void initialize()
    {
        super.initialize;

        if (!markerFactory && isCreateMarkerFactory)
        {
            markerFactory = createMarkerFactory;
        }
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

    Sprite delegate() createMarkerFactory()
    {
        return () {
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
        };
    }

    override void create()
    {
        super.create;

        if (markerFactory)
        {
            auto newMarker = markerFactory();
            marker = onMarkerCreate ? onMarkerCreate(newMarker) : newMarker;
            addCreate(marker);
            if (onMarkerCreated)
            {
                onMarkerCreated(marker);
            }

            markerState(_state);
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

    void toggle()
    {
        isOn(!_state);
    }

    bool isOff() => !isOn;

    bool isOn() => _state;

    void isOn(bool value)
    {
        if (value == _state)
        {
            return;
        }

        const bool oldValue = _state;
        _state = value;
        if (marker)
        {
            markerState = _state;
        }

        if (onOldNewValue.length > 0)
        {
            foreach (dg; onOldNewValue)
            {
                dg(oldValue, _state);
            }
        }
    }
}
