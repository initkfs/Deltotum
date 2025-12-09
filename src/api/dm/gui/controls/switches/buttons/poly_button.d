module api.dm.gui.controls.switches.buttons.poly_button;

import api.dm.gui.controls.switches.buttons.base_round_button : BaseRoundButton;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.gui.events.action_event : ActionEvent;
import api.dm.gui.controls.control : Control;

/**
 * Authors: initkfs
 */
class PolyButton : BaseRoundButton
{
    protected
    {
        size_t _sides = 0;
    }

    this(dstring text = defaultButtonText, size_t sides)
    {
        this(text, sides, 0, null, 0);
    }

    this(dstring text = defaultButtonText, string iconName, size_t sides)
    {
        this(text, sides, 0, iconName, 0);
    }

    this(dstring text, void delegate(ref ActionEvent) onAction, size_t sides = 0)
    {
        this(text, sides, 0, null, 0);
        if (onAction)
        {
            this.onAction ~= onAction;
        }
    }

    this(
        dstring text,
        size_t sides = 0,
        float diameter = 0,
        string iconName = null,
        float graphicsGap = 0,
    )
    {
        super(text, diameter, iconName, graphicsGap);

        this._sides = sides;
    }

    override void loadTheme()
    {
        loadLabeledTheme;
        loadRegPolyButtonTheme;
    }

    void loadRegPolyButtonTheme()
    {
        if (_sides == 0)
        {
            _sides = theme.regularPolySides;
        }

        if (_diameter == 0)
        {
            _diameter = theme.regularPolyDiameter;
        }

        initSize(_diameter, _diameter);
    }

    protected override Sprite2d createShape(float w, float h, float angle, GraphicStyle style)
    {
        import Math = api.math;

        auto size = (w == h) ? w : Math.max(w, h);

        return theme.regularPolyShape(size, _sides, angle, style);
    }

    size_t sides() => _sides;

    void sides(size_t v)
    {
        _sides = v;
    }
}
