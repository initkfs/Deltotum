module api.dm.gui.controls.checks.checkbox;

import api.dm.gui.controls.labeled : Labeled;
import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
class CheckBox : Labeled
{
    protected
    {
        Sprite marker;
        bool _check;
    }

    bool isCreateMarkerFactory;
    Sprite delegate() markerFactory;

    void delegate(bool, bool) onToggleOldNewValue;

    this(dstring text = "Check", string iconName = null, double graphicsGap = 5)
    {
        super(0, 0, iconName, graphicsGap, text, false);
        import api.dm.kit.sprites.layouts.hlayout : HLayout;

        layout = new HLayout(5);
        layout.isAutoResize(true);
        layout.isAlignY = true;
        _labelText = text;

        isCreateHoverEffectFactory = false;
        isCreateHoverAnimationFactory = false;
        isCreateActionEffectFactory = false;
        isCreateActionAnimationFactory = false;
        isCreateTextFactory = true;
        isCreateMarkerFactory = true;

        isBorder = true;
    }

    override void initialize()
    {
        super.initialize;
        initializeMarker;
    }

    void initializeMarker()
    {
        if (!markerFactory && isCreateMarkerFactory)
        {
            onPreControlContentCreated = () {
                markerFactory = createMarkerFactory;
            };
        }
    }

    Sprite delegate() createMarkerFactory()
    {
        return () {
            import api.dm.gui.containers.stack_box : StackBox;

            auto markerContainer = new StackBox;
            markerContainer.width = 20;
            markerContainer.height = 20;
            markerContainer.isBorder = true;
            addCreate(markerContainer);

            import api.dm.kit.sprites.shapes.convex_polygon : ConvexPolygon;
            import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

            auto marker = new ConvexPolygon(10, 10, GraphicStyle(1, theme.colorAccent, true, theme.colorAccent), 3);
            markerContainer.addCreate(marker);
            marker.isVisible = false;
            return marker;
        };
    }

    override void create()
    {
        super.create;
        enableInsets;
        onPointerDown ~= (ref e) { toggle; };

        if(markerFactory){
            marker = markerFactory();
        }
    }

    void toggle()
    {
        isCheck(!_check);
    }

    void isCheck(bool value)
    {
        if (value == _check)
        {
            return;
        }

        const bool oldValue = _check;
        _check = value;
        if (marker)
        {
            marker.isVisible = _check;
        }

        if (onToggleOldNewValue)
        {
            onToggleOldNewValue(oldValue, value);
        }
    }

    bool isCheck()
    {
        return _check;
    }
}
