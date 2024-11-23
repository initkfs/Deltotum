module api.dm.gui.controls.buttons.regular_poly_button;

import api.dm.gui.controls.buttons.base_rounded_button : BaseRoundedButton;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.gui.events.action_event : ActionEvent;
import api.dm.gui.controls.control : Control;

/**
 * Authors: initkfs
 */
class RegularPolyButton : BaseRoundedButton
{
    protected
    {
        size_t _sides = 0;
    }

    this(dstring text = defaultButtonText)
    {
        super(text);
    }

    this(dstring text, void delegate(ref ActionEvent) onAction)
    {
        super(text, onAction);
    }

    this(
        dstring text,
        size_t sides = 0,
        double diameter = 0,
        double graphicsGap = 0,
        string iconName = null,
    )
    {
        super(text, diameter, graphicsGap, iconName);

        this._sides = sides;
    }

    override void loadTheme()
    {
        loadLabeledTheme;
        loadRhombusButtonTheme;
    }

    void loadRhombusButtonTheme()
    {
        if (_sides == 0)
        {
            _sides = theme.regularPolySides;
        }

        if (_diameter == 0)
        {
            _diameter = theme.regularPolyDiameter;
            _width = _diameter;
            _height = _diameter;
        }
    }

    protected override Sprite createShape(double width, double height, GraphicStyle style)
    {
        Sprite shape;

        import Math = api.math;

        auto size = Math.max(width, height);

        if (capGraphics.isVectorGraphics)
        {
            import api.dm.kit.sprites.textures.vectors.shapes.vregular_polygon : VRegularPolygon;

            shape = new VRegularPolygon(size, style, _sides);
        }
        else
        {
            import api.dm.kit.sprites.shapes.reqular_polygon: RegularPolygon;

            shape = new RegularPolygon(size, style, _sides);
        }
        return shape;
    }
}
